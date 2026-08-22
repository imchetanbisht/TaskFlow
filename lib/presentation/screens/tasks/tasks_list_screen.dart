import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/task_filter.dart';
import '../../providers/notification_notifier.dart';
import '../../providers/project_notifier.dart';
import '../../providers/task_filter_notifier.dart';
import '../../providers/task_notifier.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/error_state_view.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/task_card.dart';
import 'task_details_screen.dart';
import 'task_form_screen.dart';

class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredTasksAsync = ref.watch(filteredTasksProvider);
    final filter = ref.watch(taskFilterProvider);
    final filterNotifier = ref.read(taskFilterProvider.notifier);
    final orgMembersAsync = ref.watch(orgMembersProvider);
    final projectsAsync = ref.watch(projectsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Task',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TaskFormScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    hint: 'Search tasks...',
                    controller: _searchController,
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                    onChanged: (val) => filterNotifier.setSearchQuery(val),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.tune_rounded, size: 20),
                      if (filter.activeFilterCount > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                            child: Text(
                              '${filter.activeFilterCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () => FilterBottomSheet.show(context),
                ),
              ],
            ),
          ),

          // Active Filter Chips Bar (if any)
          if (filter.hasActiveFilters)
            Container(
              height: 38,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Clear all chip
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      avatar: const Icon(Icons.close, size: 14, color: AppColors.error),
                      label: const Text('Clear All'),
                      labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
                      onPressed: () {
                        _searchController.clear();
                        filterNotifier.clearAllFilters();
                      },
                    ),
                  ),
                  // Status chips
                  ...filter.selectedStatuses.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text(s.label),
                        labelStyle: AppTextStyles.labelSmall,
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => filterNotifier.toggleStatus(s),
                      ),
                    ),
                  ),
                  // Priority chips
                  ...filter.selectedPriorities.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text(p.label),
                        labelStyle: AppTextStyles.labelSmall,
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => filterNotifier.togglePriority(p),
                      ),
                    ),
                  ),
                  // Due date chip
                  if (filter.dueDateFilter != DueDateFilter.all)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text('Due: ${filter.dueDateFilter.label}'),
                        labelStyle: AppTextStyles.labelSmall,
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => filterNotifier.setDueDateFilter(DueDateFilter.all),
                      ),
                    ),
                  // Assignee chip
                  if (filter.selectedAssigneeId != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text(
                          filter.selectedAssigneeId == 'unassigned'
                              ? 'Assignee: Unassigned'
                              : 'Assignee: ${orgMembersAsync.asData?.value.where((m) => m.id == filter.selectedAssigneeId).firstOrNull?.name ?? "User"}',
                        ),
                        labelStyle: AppTextStyles.labelSmall,
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => filterNotifier.setAssignee(null),
                      ),
                    ),
                ],
              ),
            ),

          // Tasks List
          Expanded(
            child: filteredTasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.assignment_late_outlined,
                    title: filter.hasActiveFilters ? 'No matching tasks' : 'No tasks yet',
                    description: filter.hasActiveFilters
                        ? 'Try clearing or changing your filters.'
                        : 'Create your first task to get things done.',
                    actionLabel: filter.hasActiveFilters ? 'Clear Filters' : 'Create Task',
                    onAction: filter.hasActiveFilters
                        ? () {
                            _searchController.clear();
                            filterNotifier.clearAllFilters();
                          }
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const TaskFormScreen()),
                            );
                          },
                  );
                }

                final members = orgMembersAsync.asData?.value ?? [];
                final projects = projectsAsync.asData?.value ?? [];

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(tasksNotifierProvider.notifier)
                      .loadTasks(forceRefresh: true),
                  child: ListView.builder(
                    itemCount: tasks.length,
                    padding: const EdgeInsets.only(bottom: 24),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final assignee =
                          members.where((m) => m.id == task.assigneeId).firstOrNull;
                      final project =
                          projects.where((p) => p.id == task.projectId).firstOrNull;

                      return TaskCard(
                        task: task,
                        projectName: project?.name,
                        assignee: assignee,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TaskDetailsScreen(taskId: task.id),
                            ),
                          );
                        },
                        onStatusChanged: (newStatus) {
                          ref
                              .read(tasksNotifierProvider.notifier)
                              .updateStatus(task.id, newStatus);
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => ListView(
                children: const [
                  TaskCardSkeleton(),
                  TaskCardSkeleton(),
                  TaskCardSkeleton(),
                ],
              ),
              error: (err, _) => ErrorStateView(
                message: err.toString(),
                onRetry: () => ref
                    .read(tasksNotifierProvider.notifier)
                    .loadTasks(forceRefresh: true),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TaskFormScreen()),
          );
        },
        backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
        foregroundColor: isDark ? Colors.black : Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
