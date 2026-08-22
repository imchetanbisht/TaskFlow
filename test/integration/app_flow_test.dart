import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/storage/local_storage_service.dart';
import 'package:taskflow/core/storage/secure_storage_service.dart';
import 'package:taskflow/data/datasources/local_cache_data_source.dart';
import 'package:taskflow/data/datasources/mock_data_source.dart';
import 'package:taskflow/data/repositories/auth_repository_impl.dart';
import 'package:taskflow/data/repositories/project_repository_impl.dart';
import 'package:taskflow/data/repositories/task_repository_impl.dart';
import 'package:taskflow/data/repositories/user_repository_impl.dart';
import 'package:taskflow/domain/entities/task.dart';
import 'package:taskflow/domain/usecases/auth_usecases.dart';
import 'package:taskflow/domain/usecases/project_usecases.dart';
import 'package:taskflow/domain/usecases/task_usecases.dart';

import '../test_mock_data.dart';

void main() {
  late MockDataSource mockDataSource;
  late ISecureStorageService secureStorage;
  late ILocalStorageService localStorage;
  late LocalCacheDataSource cacheDataSource;
  late AuthRepositoryImpl authRepo;
  late ProjectRepositoryImpl projectRepo;
  late TaskRepositoryImpl taskRepo;
  late UserRepositoryImpl userRepo;

  late LoginUseCase loginUseCase;
  late GetProjectsUseCase getProjectsUseCase;
  late CreateProjectUseCase createProjectUseCase;
  late GetTasksUseCase getTasksUseCase;
  late CreateTaskUseCase createTaskUseCase;
  late UpdateTaskStatusUseCase updateStatusUseCase;
  late LogoutUseCase logoutUseCase;

  setUp(() async {
    mockDataSource = MockDataSource();
    await mockDataSource.initialize(rawJson: testMockDataJson);
    secureStorage = InMemorySecureStorageService();
    localStorage = InMemoryLocalStorageService();
    cacheDataSource = LocalCacheDataSource(
      localStorage: localStorage,
      secureStorage: secureStorage,
    );

    authRepo = AuthRepositoryImpl(
      mockDataSource: mockDataSource,
      cacheDataSource: cacheDataSource,
    );
    projectRepo = ProjectRepositoryImpl(
      mockDataSource: mockDataSource,
      cacheDataSource: cacheDataSource,
    );
    taskRepo = TaskRepositoryImpl(
      mockDataSource: mockDataSource,
      cacheDataSource: cacheDataSource,
    );
    userRepo = UserRepositoryImpl(mockDataSource: mockDataSource);

    loginUseCase = LoginUseCase(authRepo);
    getProjectsUseCase = GetProjectsUseCase(projectRepo);
    createProjectUseCase = CreateProjectUseCase(projectRepo);
    getTasksUseCase = GetTasksUseCase(taskRepo);
    createTaskUseCase = CreateTaskUseCase(
      taskRepository: taskRepo,
      projectRepository: projectRepo,
      userRepository: userRepo,
    );
    updateStatusUseCase = UpdateTaskStatusUseCase(taskRepo);
    logoutUseCase = LogoutUseCase(authRepo);
  });

  group('Full Application Integration Flow Test', () {
    test('Complete user workflow: Login -> Projects -> Tasks -> Status -> Logout',
        () async {
      // 1. Login as Admin
      final session = await loginUseCase.execute(
        email: 'ava.admin@nimbusdigital.test',
        password: 'Password123!',
      );
      expect(session.user.name, 'Ava Thompson');
      expect(session.isAdmin, true);

      // 2. Fetch Projects scoped to Org
      final initialProjects = await getProjectsUseCase.execute(session.organization.id);
      expect(initialProjects.isNotEmpty, true);
      final orgProj = initialProjects.first;
      expect(orgProj.name, 'Website Relaunch');

      // 3. Create a new project
      final newProj = await createProjectUseCase.execute(
        name: 'Brand Identity',
        description: 'New design system assets and guidelines',
        session: session,
      );
      expect(newProj.name, 'Brand Identity');

      // 4. Fetch Tasks
      final initialTasks = await getTasksUseCase.execute(session.organization.id);
      expect(initialTasks.length, 2);

      // 5. Create a new task in new project
      final newTask = await createTaskUseCase.execute(
        projectId: newProj.id,
        title: 'Design New Logo',
        description: 'Vector logo guidelines',
        status: TaskStatus.todo,
        priority: TaskPriority.urgent,
        assigneeId: 'user_002', // Marcus in Org A
        session: session,
      );
      expect(newTask.title, 'Design New Logo');
      expect(newTask.status, TaskStatus.todo);

      // 6. Update task status from To Do to In Progress to Done
      final inProgressTask = await updateStatusUseCase.execute(
        taskId: newTask.id,
        newStatus: TaskStatus.inProgress,
      );
      expect(inProgressTask.status, TaskStatus.inProgress);

      final doneTask = await updateStatusUseCase.execute(
        taskId: newTask.id,
        newStatus: TaskStatus.done,
      );
      expect(doneTask.status, TaskStatus.done);

      // 7. Verify task count in project
      final updatedProjects = await getProjectsUseCase.execute(session.organization.id);
      final brandProject = updatedProjects.firstWhere((p) => p.id == newProj.id);
      expect(brandProject.taskCount, 1);

      // 8. Logout
      await logoutUseCase.execute();
      final currentSession = await authRepo.getCurrentSession();
      expect(currentSession, isNull);
    });
  });
}
