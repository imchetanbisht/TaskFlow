import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/comment.dart';
import '../../domain/entities/task.dart';
import 'app_providers.dart';
import 'auth_notifier.dart';
import 'project_notifier.dart';

class TasksNotifier extends StateNotifier<AsyncValue<List<TaskItem>>> {
  final Ref _ref;

  TasksNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks({bool forceRefresh = false}) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState is! Authenticated) {
      state = const AsyncValue.data([]);
      return;
    }

    if (!forceRefresh && state is! AsyncLoading) {
      state = const AsyncValue.loading();
    }

    try {
      final tasks = await _ref
          .read(getTasksUseCaseProvider)
          .execute(authState.session.organization.id, forceRefresh: forceRefresh);
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<TaskItem> createTask({
    required String projectId,
    required String title,
    required String description,
    required TaskStatus status,
    required TaskPriority priority,
    String? assigneeId,
    DateTime? dueDate,
  }) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState is! Authenticated) {
      throw Exception('User is not authenticated');
    }

    final task = await _ref.read(createTaskUseCaseProvider).execute(
          projectId: projectId,
          title: title,
          description: description,
          status: status,
          priority: priority,
          assigneeId: assigneeId,
          dueDate: dueDate,
          session: authState.session,
        );

    await loadTasks(forceRefresh: true);
    // Also refresh project task counts
    _ref.read(projectsNotifierProvider.notifier).loadProjects(forceRefresh: true);
    return task;
  }

  Future<TaskItem> updateTask(TaskItem task) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState is! Authenticated) {
      throw Exception('User is not authenticated');
    }

    final updated = await _ref.read(updateTaskUseCaseProvider).execute(
          task: task,
          session: authState.session,
        );

    await loadTasks(forceRefresh: true);
    return updated;
  }

  Future<void> deleteTask(String taskId) async {
    await _ref.read(deleteTaskUseCaseProvider).execute(taskId);
    await loadTasks(forceRefresh: true);
    // Also refresh project task counts
    _ref.read(projectsNotifierProvider.notifier).loadProjects(forceRefresh: true);
  }

  Future<void> updateStatus(String taskId, TaskStatus status) async {
    await _ref.read(updateTaskStatusUseCaseProvider).execute(
          taskId: taskId,
          newStatus: status,
        );
    await loadTasks(forceRefresh: true);
  }

  Future<void> updatePriority(String taskId, TaskPriority priority) async {
    await _ref.read(updateTaskPriorityUseCaseProvider).execute(
          taskId: taskId,
          newPriority: priority,
        );
    await loadTasks(forceRefresh: true);
  }

  Future<void> assignTask(String taskId, String? assigneeId) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState is! Authenticated) {
      throw Exception('User is not authenticated');
    }

    await _ref.read(assignTaskUseCaseProvider).execute(
          taskId: taskId,
          assigneeId: assigneeId,
          session: authState.session,
        );
    await loadTasks(forceRefresh: true);
  }

  Future<CommentItem> addComment(String taskId, String body) async {
    final authState = _ref.read(authNotifierProvider);
    if (authState is! Authenticated) {
      throw Exception('User is not authenticated');
    }

    final comment = await _ref.read(addCommentUseCaseProvider).execute(
          taskId: taskId,
          body: body,
          session: authState.session,
        );

    return comment;
  }

  Future<List<CommentItem>> getComments(String taskId) async {
    return await _ref.read(getCommentsUseCaseProvider).execute(taskId);
  }
}

final tasksNotifierProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<TaskItem>>>((ref) {
  return TasksNotifier(ref);
});

final taskByIdProvider = Provider.family<TaskItem?, String>((ref, taskId) {
  final tasksAsync = ref.watch(tasksNotifierProvider);
  return tasksAsync.when(
    data: (tasks) {
      try {
        return tasks.firstWhere((t) => t.id == taskId);
      } catch (_) {
        return null;
      }
    },
    loading: () => null,
    error: (e, st) => null,
  );
});

final taskCommentsProvider =
    FutureProvider.family<List<CommentItem>, String>((ref, taskId) async {
  return await ref.read(tasksNotifierProvider.notifier).getComments(taskId);
});
