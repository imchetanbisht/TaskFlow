import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/errors/app_exception.dart';
import 'package:taskflow/core/storage/local_storage_service.dart';
import 'package:taskflow/core/storage/secure_storage_service.dart';
import 'package:taskflow/data/datasources/local_cache_data_source.dart';
import 'package:taskflow/data/datasources/mock_data_source.dart';
import 'package:taskflow/data/repositories/project_repository_impl.dart';
import 'package:taskflow/data/repositories/task_repository_impl.dart';
import 'package:taskflow/data/repositories/user_repository_impl.dart';
import 'package:taskflow/domain/entities/auth_session.dart';
import 'package:taskflow/domain/entities/organization.dart';
import 'package:taskflow/domain/entities/task.dart';
import 'package:taskflow/domain/entities/user.dart';
import 'package:taskflow/domain/usecases/project_usecases.dart';
import 'package:taskflow/domain/usecases/task_usecases.dart';

import '../test_mock_data.dart';

void main() {
  late MockDataSource mockDataSource;
  late ProjectRepositoryImpl projectRepo;
  late TaskRepositoryImpl taskRepo;
  late UserRepositoryImpl userRepo;
  late DeleteProjectUseCase deleteProjectUseCase;
  late AssignTaskUseCase assignTaskUseCase;
  late CreateTaskUseCase createTaskUseCase;

  late AuthSession adminSession;
  late AuthSession memberSession;

  setUp(() async {
    mockDataSource = MockDataSource();
    await mockDataSource.initialize(rawJson: testMockDataJson);
    final secureStorage = InMemorySecureStorageService();
    final localStorage = InMemoryLocalStorageService();
    final cacheDataSource = LocalCacheDataSource(
      localStorage: localStorage,
      secureStorage: secureStorage,
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

    deleteProjectUseCase = DeleteProjectUseCase(projectRepo);
    assignTaskUseCase = AssignTaskUseCase(
      taskRepository: taskRepo,
      userRepository: userRepo,
    );
    createTaskUseCase = CreateTaskUseCase(
      taskRepository: taskRepo,
      projectRepository: projectRepo,
      userRepository: userRepo,
    );

    adminSession = AuthSession(
      accessToken: 'token1',
      refreshToken: 'rtoken1',
      accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
      user: const User(
        id: 'user_001',
        name: 'Ava Thompson',
        email: 'ava.admin@nimbusdigital.test',
      ),
      organization: const Organization(id: 'org_a1b2c3', name: 'Nimbus Digital'),
      role: UserRole.orgAdmin,
    );

    memberSession = AuthSession(
      accessToken: 'token2',
      refreshToken: 'rtoken2',
      accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
      user: const User(
        id: 'user_002',
        name: 'Marcus Lee',
        email: 'marcus.member@nimbusdigital.test',
      ),
      organization: const Organization(id: 'org_a1b2c3', name: 'Nimbus Digital'),
      role: UserRole.member,
    );
  });

  group('Role Authorization & Business Logic Tests', () {
    test('Org Admin can delete project belonging to their org', () async {
      await deleteProjectUseCase.execute(
        projectId: 'proj_1001',
        session: adminSession,
      );

      final project = await projectRepo.getProjectById('proj_1001');
      expect(project, isNull);
    });

    test('Member is blocked from deleting project', () async {
      expect(
        () => deleteProjectUseCase.execute(
          projectId: 'proj_1001',
          session: memberSession,
        ),
        throwsA(isA<AuthorizationException>()),
      );
    });

    test('Assigning user from same org succeeds', () async {
      final updated = await assignTaskUseCase.execute(
        taskId: 'task_2001',
        assigneeId: 'user_003', // Priya in Org A
        session: adminSession,
      );

      expect(updated.assigneeId, 'user_003');
    });

    test('Assigning user from another organization is rejected by business logic', () async {
      expect(
        () => assignTaskUseCase.execute(
          taskId: 'task_2001',
          assigneeId: 'user_004', // Daniel in Org B
          session: adminSession,
        ),
        throwsA(isA<AuthorizationException>()),
      );
    });

    test('Creating task in a foreign organization project is rejected', () async {
      expect(
        () => createTaskUseCase.execute(
          projectId: 'proj_1003', // Belongs to Org B
          title: 'Unauthorized Task',
          description: 'Desc',
          status: TaskStatus.todo,
          priority: TaskPriority.medium,
          session: adminSession, // Admin of Org A
        ),
        throwsA(isA<AuthorizationException>()),
      );
    });
  });
}
