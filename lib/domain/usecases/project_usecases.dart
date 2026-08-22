import '../../core/errors/app_exception.dart';
import '../entities/auth_session.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository _repository;
  GetProjectsUseCase(this._repository);

  Future<List<Project>> execute(String orgId, {bool forceRefresh = false}) async {
    return await _repository.getProjects(orgId, forceRefresh: forceRefresh);
  }
}

class GetProjectByIdUseCase {
  final ProjectRepository _repository;
  GetProjectByIdUseCase(this._repository);

  Future<Project?> execute(String projectId) async {
    return await _repository.getProjectById(projectId);
  }
}

class CreateProjectUseCase {
  final ProjectRepository _repository;
  CreateProjectUseCase(this._repository);

  Future<Project> execute({
    required String name,
    required String description,
    required AuthSession session,
  }) async {
    if (name.trim().isEmpty) {
      throw const ValidationException(
        'Project name cannot be empty',
        fieldErrors: {'name': 'Project name is required'},
      );
    }

    final project = Project(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      orgId: session.organization.id,
      name: name.trim(),
      description: description.trim(),
      taskCount: 0,
      status: 'active',
      createdAt: DateTime.now(),
    );

    return await _repository.createProject(project);
  }
}

class UpdateProjectUseCase {
  final ProjectRepository _repository;
  UpdateProjectUseCase(this._repository);

  Future<Project> execute({
    required Project project,
    required AuthSession session,
  }) async {
    if (project.name.trim().isEmpty) {
      throw const ValidationException(
        'Project name cannot be empty',
        fieldErrors: {'name': 'Project name is required'},
      );
    }

    // Role check: Only admin or members within the same org can edit
    if (project.orgId != session.organization.id) {
      throw const AuthorizationException(
        'You cannot modify projects from another organization.',
      );
    }

    return await _repository.updateProject(project);
  }
}

class DeleteProjectUseCase {
  final ProjectRepository _repository;
  DeleteProjectUseCase(this._repository);

  Future<void> execute({
    required String projectId,
    required AuthSession session,
  }) async {
    // Admin only rule enforced in business logic!
    if (!session.isAdmin) {
      throw const AuthorizationException(
        'Only Organization Admins are authorized to delete projects.',
      );
    }

    final project = await _repository.getProjectById(projectId);
    if (project != null && project.orgId != session.organization.id) {
      throw const AuthorizationException(
        'You cannot delete projects belonging to another organization.',
      );
    }

    await _repository.deleteProject(projectId);
  }
}
