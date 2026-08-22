import '../../core/errors/app_exception.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local_cache_data_source.dart';
import '../datasources/mock_data_source.dart';
import '../models/comment_model.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final MockDataSource _mockDataSource;
  final LocalCacheDataSource _cacheDataSource;

  TaskRepositoryImpl({
    required MockDataSource mockDataSource,
    required LocalCacheDataSource cacheDataSource,
  })  : _mockDataSource = mockDataSource,
        _cacheDataSource = cacheDataSource;

  @override
  Future<List<TaskItem>> getTasksByOrg(String orgId, {bool forceRefresh = false}) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }

    try {
      final models = await _mockDataSource.getTasksByOrg(orgId);
      await _cacheDataSource.cacheTasks(orgId, models);
      return models;
    } on OfflineException {
      final cached = await _cacheDataSource.getCachedTasks(orgId);
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<List<TaskItem>> getTasksByProject(String projectId) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }
    return await _mockDataSource.getTasksByProject(projectId);
  }

  @override
  Future<TaskItem?> getTaskById(String taskId) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }
    return await _mockDataSource.getTaskById(taskId);
  }

  @override
  Future<TaskItem> createTask(TaskItem task) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }
    final model = TaskModel.fromEntity(task);
    final created = await _mockDataSource.createTask(model);
    
    // Find project to get orgId and update cache
    final project = await _mockDataSource.getProjectById(task.projectId);
    if (project != null) {
      final updatedList = await _mockDataSource.getTasksByOrg(project.orgId);
      await _cacheDataSource.cacheTasks(project.orgId, updatedList);
    }
    
    return created;
  }

  @override
  Future<TaskItem> updateTask(TaskItem task) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }
    final model = TaskModel.fromEntity(task);
    final updated = await _mockDataSource.updateTask(model);
    
    final project = await _mockDataSource.getProjectById(task.projectId);
    if (project != null) {
      final updatedList = await _mockDataSource.getTasksByOrg(project.orgId);
      await _cacheDataSource.cacheTasks(project.orgId, updatedList);
    }
    
    return updated;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }

    final task = await _mockDataSource.getTaskById(taskId);
    final project = task != null ? await _mockDataSource.getProjectById(task.projectId) : null;
    final orgId = project?.orgId;

    await _mockDataSource.deleteTask(taskId);

    if (orgId != null) {
      final updatedList = await _mockDataSource.getTasksByOrg(orgId);
      await _cacheDataSource.cacheTasks(orgId, updatedList);
    }
  }

  @override
  Future<List<CommentItem>> getComments(String taskId) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }
    return await _mockDataSource.getCommentsByTask(taskId);
  }

  @override
  Future<CommentItem> addComment(CommentItem comment) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }
    final model = CommentModel.fromEntity(comment);
    return await _mockDataSource.addComment(model);
  }
}
