import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/project.dart';
import 'app_providers.dart';
import 'auth_notifier.dart';

class ProjectsNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final Ref _ref;

  ProjectsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadProjects();
  }

  Future<void> loadProjects({bool forceRefresh = false}) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState is! Authenticated) {
      state = const AsyncValue.data([]);
      return;
    }

    if (!forceRefresh && state is! AsyncLoading) {
      state = const AsyncValue.loading();
    }

    try {
      final projects = await _ref
          .read(getProjectsUseCaseProvider)
          .execute(authState.session.organization.id, forceRefresh: forceRefresh);
      state = AsyncValue.data(projects);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Project> createProject({
    required String name,
    required String description,
  }) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState is! Authenticated) {
      throw Exception('User is not authenticated');
    }

    final project = await _ref.read(createProjectUseCaseProvider).execute(
          name: name,
          description: description,
          session: authState.session,
        );

    await loadProjects(forceRefresh: true);
    return project;
  }

  Future<Project> updateProject(Project project) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState is! Authenticated) {
      throw Exception('User is not authenticated');
    }

    final updated = await _ref.read(updateProjectUseCaseProvider).execute(
          project: project,
          session: authState.session,
        );

    await loadProjects(forceRefresh: true);
    return updated;
  }

  Future<void> deleteProject(String projectId) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState is! Authenticated) {
      throw Exception('User is not authenticated');
    }

    await _ref.read(deleteProjectUseCaseProvider).execute(
          projectId: projectId,
          session: authState.session,
        );

    await loadProjects(forceRefresh: true);
  }
}

final projectsNotifierProvider =
    StateNotifierProvider<ProjectsNotifier, AsyncValue<List<Project>>>((ref) {
  return ProjectsNotifier(ref);
});

final projectByIdProvider = Provider.family<Project?, String>((ref, projectId) {
  final projectsAsync = ref.watch(projectsNotifierProvider);
  return projectsAsync.when(
    data: (projects) {
      try {
        return projects.firstWhere((p) => p.id == projectId);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (e, st) => null,
  );
});
