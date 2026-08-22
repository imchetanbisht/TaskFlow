import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> getProjects(String orgId, {bool forceRefresh = false});
  Future<Project?> getProjectById(String projectId);
  Future<Project> createProject(Project project);
  Future<Project> updateProject(Project project);
  Future<void> deleteProject(String projectId);
}
