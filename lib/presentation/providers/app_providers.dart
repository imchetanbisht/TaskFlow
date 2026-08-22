import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/debug/debug_simulation_service.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../data/datasources/local_cache_data_source.dart';
import '../../data/datasources/mock_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/project_usecases.dart';
import '../../domain/usecases/task_usecases.dart';
import '../../domain/usecases/user_usecases.dart';

// Storage providers
final localStorageServiceProvider = Provider<ILocalStorageService>((ref) {
  throw UnimplementedError('Initialize with SharedPreferences instance in main.dart');
});

final secureStorageServiceProvider = Provider<ISecureStorageService>((ref) {
  return SecureStorageService();
});

// Debug simulation service
final debugSimulationServiceProvider = Provider<DebugSimulationService>((ref) {
  return DebugSimulationService();
});

// Data Sources
final mockDataSourceProvider = Provider<MockDataSource>((ref) {
  final debugService = ref.watch(debugSimulationServiceProvider);
  return MockDataSource(debugSimulation: debugService);
});

final localCacheDataSourceProvider = Provider<LocalCacheDataSource>((ref) {
  final local = ref.watch(localStorageServiceProvider);
  final secure = ref.watch(secureStorageServiceProvider);
  return LocalCacheDataSource(localStorage: local, secureStorage: secure);
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final mockData = ref.watch(mockDataSourceProvider);
  final cache = ref.watch(localCacheDataSourceProvider);
  return AuthRepositoryImpl(mockDataSource: mockData, cacheDataSource: cache);
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final mockData = ref.watch(mockDataSourceProvider);
  final cache = ref.watch(localCacheDataSourceProvider);
  return ProjectRepositoryImpl(mockDataSource: mockData, cacheDataSource: cache);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final mockData = ref.watch(mockDataSourceProvider);
  final cache = ref.watch(localCacheDataSourceProvider);
  return TaskRepositoryImpl(mockDataSource: mockData, cacheDataSource: cache);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final mockData = ref.watch(mockDataSourceProvider);
  return UserRepositoryImpl(mockDataSource: mockData);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final mockData = ref.watch(mockDataSourceProvider);
  return NotificationRepositoryImpl(mockDataSource: mockData);
});

// Auth Use Cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentSessionUseCaseProvider = Provider<GetCurrentSessionUseCase>((ref) {
  return GetCurrentSessionUseCase(ref.watch(authRepositoryProvider));
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  return RefreshTokenUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

// Project Use Cases
final getProjectsUseCaseProvider = Provider<GetProjectsUseCase>((ref) {
  return GetProjectsUseCase(ref.watch(projectRepositoryProvider));
});

final getProjectByIdUseCaseProvider = Provider<GetProjectByIdUseCase>((ref) {
  return GetProjectByIdUseCase(ref.watch(projectRepositoryProvider));
});

final createProjectUseCaseProvider = Provider<CreateProjectUseCase>((ref) {
  return CreateProjectUseCase(ref.watch(projectRepositoryProvider));
});

final updateProjectUseCaseProvider = Provider<UpdateProjectUseCase>((ref) {
  return UpdateProjectUseCase(ref.watch(projectRepositoryProvider));
});

final deleteProjectUseCaseProvider = Provider<DeleteProjectUseCase>((ref) {
  return DeleteProjectUseCase(ref.watch(projectRepositoryProvider));
});

// Task Use Cases
final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
});

final filterTasksUseCaseProvider = Provider<FilterTasksUseCase>((ref) {
  return FilterTasksUseCase();
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(
    taskRepository: ref.watch(taskRepositoryProvider),
    projectRepository: ref.watch(projectRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCase(
    taskRepository: ref.watch(taskRepositoryProvider),
    projectRepository: ref.watch(projectRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

final assignTaskUseCaseProvider = Provider<AssignTaskUseCase>((ref) {
  return AssignTaskUseCase(
    taskRepository: ref.watch(taskRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

final updateTaskStatusUseCaseProvider = Provider<UpdateTaskStatusUseCase>((ref) {
  return UpdateTaskStatusUseCase(ref.watch(taskRepositoryProvider));
});

final updateTaskPriorityUseCaseProvider = Provider<UpdateTaskPriorityUseCase>((ref) {
  return UpdateTaskPriorityUseCase(ref.watch(taskRepositoryProvider));
});

final getCommentsUseCaseProvider = Provider<GetCommentsUseCase>((ref) {
  return GetCommentsUseCase(ref.watch(taskRepositoryProvider));
});

final addCommentUseCaseProvider = Provider<AddCommentUseCase>((ref) {
  return AddCommentUseCase(ref.watch(taskRepositoryProvider));
});

// User & Notification Use Cases
final getOrgMembersUseCaseProvider = Provider<GetOrgMembersUseCase>((ref) {
  return GetOrgMembersUseCase(ref.watch(userRepositoryProvider));
});

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  return GetNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});

final markNotificationReadUseCaseProvider = Provider<MarkNotificationReadUseCase>((ref) {
  return MarkNotificationReadUseCase(ref.watch(notificationRepositoryProvider));
});
