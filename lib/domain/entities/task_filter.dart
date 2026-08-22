import 'task.dart';

enum DueDateFilter {
  all('All'),
  today('Today'),
  thisWeek('This Week'),
  overdue('Overdue');

  final String label;
  const DueDateFilter(this.label);
}

class TaskFilter {
  final String searchQuery;
  final Set<TaskStatus> selectedStatuses;
  final Set<TaskPriority> selectedPriorities;
  final String? selectedAssigneeId;
  final String? selectedProjectId;
  final DueDateFilter dueDateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;

  const TaskFilter({
    this.searchQuery = '',
    this.selectedStatuses = const {},
    this.selectedPriorities = const {},
    this.selectedAssigneeId,
    this.selectedProjectId,
    this.dueDateFilter = DueDateFilter.all,
    this.customStartDate,
    this.customEndDate,
  });

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedStatuses.isNotEmpty ||
      selectedPriorities.isNotEmpty ||
      selectedAssigneeId != null ||
      selectedProjectId != null ||
      dueDateFilter != DueDateFilter.all ||
      customStartDate != null ||
      customEndDate != null;

  int get activeFilterCount {
    int count = 0;
    if (selectedStatuses.isNotEmpty) count += selectedStatuses.length;
    if (selectedPriorities.isNotEmpty) count += selectedPriorities.length;
    if (selectedAssigneeId != null) count++;
    if (selectedProjectId != null) count++;
    if (dueDateFilter != DueDateFilter.all) count++;
    if (customStartDate != null || customEndDate != null) count++;
    return count;
  }

  TaskFilter copyWith({
    String? searchQuery,
    Set<TaskStatus>? selectedStatuses,
    Set<TaskPriority>? selectedPriorities,
    String? selectedAssigneeId,
    bool clearAssignee = false,
    String? selectedProjectId,
    bool clearProject = false,
    DueDateFilter? dueDateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool clearCustomDates = false,
  }) {
    return TaskFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatuses: selectedStatuses ?? this.selectedStatuses,
      selectedPriorities: selectedPriorities ?? this.selectedPriorities,
      selectedAssigneeId:
          clearAssignee ? null : (selectedAssigneeId ?? this.selectedAssigneeId),
      selectedProjectId:
          clearProject ? null : (selectedProjectId ?? this.selectedProjectId),
      dueDateFilter: dueDateFilter ?? this.dueDateFilter,
      customStartDate:
          clearCustomDates ? null : (customStartDate ?? this.customStartDate),
      customEndDate:
          clearCustomDates ? null : (customEndDate ?? this.customEndDate),
    );
  }

  static TaskFilter empty() => const TaskFilter();
}
