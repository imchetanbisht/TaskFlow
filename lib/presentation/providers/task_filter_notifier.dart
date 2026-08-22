import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import 'app_providers.dart';
import 'task_notifier.dart';

class TaskFilterNotifier extends StateNotifier<TaskFilter> {
  TaskFilterNotifier() : super(const TaskFilter());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleStatus(TaskStatus status) {
    final current = Set<TaskStatus>.from(state.selectedStatuses);
    if (current.contains(status)) {
      current.remove(status);
    } else {
      current.add(status);
    }
    state = state.copyWith(selectedStatuses: current);
  }

  void togglePriority(TaskPriority priority) {
    final current = Set<TaskPriority>.from(state.selectedPriorities);
    if (current.contains(priority)) {
      current.remove(priority);
    } else {
      current.add(priority);
    }
    state = state.copyWith(selectedPriorities: current);
  }

  void setAssignee(String? assigneeId) {
    if (assigneeId == null) {
      state = state.copyWith(clearAssignee: true);
    } else {
      state = state.copyWith(selectedAssigneeId: assigneeId);
    }
  }

  void setProject(String? projectId) {
    if (projectId == null) {
      state = state.copyWith(clearProject: true);
    } else {
      state = state.copyWith(selectedProjectId: projectId);
    }
  }

  void setDueDateFilter(DueDateFilter filter) {
    state = state.copyWith(dueDateFilter: filter);
  }

  void setCustomDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      customStartDate: start,
      customEndDate: end,
    );
  }

  void setFilter(TaskFilter filter) {
    state = filter;
  }

  void clearAllFilters() {
    state = const TaskFilter();
  }
}

final taskFilterProvider =
    StateNotifierProvider<TaskFilterNotifier, TaskFilter>((ref) {
  return TaskFilterNotifier();
});

final filteredTasksProvider = Provider<AsyncValue<List<TaskItem>>>((ref) {
  final tasksAsync = ref.watch(tasksNotifierProvider);
  final filter = ref.watch(taskFilterProvider);
  final filterUseCase = ref.watch(filterTasksUseCaseProvider);

  return tasksAsync.when(
    data: (tasks) {
      final filtered = filterUseCase.execute(tasks, filter);
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
