import '../../core/errors/app_exception.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/local_cache_data_source.dart';
import '../datasources/mock_data_source.dart';
import '../models/project_model.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final MockDataSource _mockDataSource;
  final LocalCacheDataSource _cacheDataSource;

  ProjectRepositoryImpl({
    required MockDataSource mockDataSource,
    required LocalCacheDataSource cacheDataSource,
  })  : _mockDataSource = mockDataSource,
        _cacheDataSource = cacheDataSource;

  @override
  Future<List<Project>> getProjects(String orgId, {bool forceRefresh = false}) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }

    try {
      final models = await _mockDataSource.getProjectsByOrg(orgId);
      // Cache successful response
      await _cacheDataSource.cacheProjects(orgId, models);
      return models;
    } on OfflineException {
      // Return cached data if offline
      final cached = await _cacheDataSource.getCachedProjects(orgId);
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<Project?> getProjectById(String projectId) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }
    return await _mockDataSource.getProjectById(projectId);
  }

  @override
  Future<Project> createProject(Project project) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }
    final model = ProjectModel.fromEntity(project);
    final created = await _mockDataSource.createProject(model);
    
    // Refresh cache
    final updatedList = await _mockDataSource.getProjectsByOrg(project.orgId);
    await _cacheDataSource.cacheProjects(project.orgId, updatedList);
    
    return created;
  }

  @override
  Future<Project> updateProject(Project project) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }
    final model = ProjectModel.fromEntity(project);
    final updated = await _mockDataSource.updateProject(model);
    
    // Refresh cache
    final updatedList = await _mockDataSource.getProjectsByOrg(project.orgId);
    await _cacheDataSource.cacheProjects(project.orgId, updatedList);
    
    return updated;
  }

  @override
  Future<void> deleteProject(String projectId) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }
    
    final project = await _mockDataSource.getProjectById(projectId);
    final orgId = project?.orgId;
    
    await _mockDataSource.deleteProject(projectId);

    if (orgId != null) {
      final updatedList = await _mockDataSource.getProjectsByOrg(orgId);
      await _cacheDataSource.cacheProjects(orgId, updatedList);
    }
  }
}
