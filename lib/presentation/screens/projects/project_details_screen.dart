import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/task.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/notification_notifier.dart';
import '../../providers/project_notifier.dart';
import '../../providers/task_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/task_card.dart';
import '../tasks/task_details_screen.dart';
import '../tasks/task_form_screen.dart';
import 'project_form_screen.dart';

class ProjectDetailsScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectByIdProvider(projectId));
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final session = authState.session;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyStateView(
          icon: Icons.error_outline_rounded,
          title: 'Project not found',
          description: 'The requested project could not be found or was removed.',
          actionLabel: 'Back to Projects',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    final tasksAsync = ref.watch(tasksNotifierProvider);
    final orgMembersAsync = ref.watch(orgMembersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          if (session.isAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (val) {
                if (val == 'edit') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProjectFormScreen(project: project),
                    ),
                  );
                } else if (val == 'delete') {
                  ConfirmationDialog.show(
                    context: context,
                    title: 'Delete project?',
                    message:
                        'Are you sure you want to delete "${project.name}"? This action cannot be undone.',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                    onConfirm: () async {
                      try {
                        await ref
                            .read(projectsNotifierProvider.notifier)
                            .deleteProject(project.id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Project deleted successfully'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit Project'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete Project', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: tasksAsync.when(
        data: (allTasks) {
          final projectTasks =
              allTasks.where((t) => t.projectId == project.id).toList();

          final todoCount =
              projectTasks.where((t) => t.status == TaskStatus.todo).length;
          final inProgCount =
              projectTasks.where((t) => t.status == TaskStatus.inProgress).length;
          final reviewCount =
              projectTasks.where((t) => t.status == TaskStatus.review).length;
          final doneCount =
              projectTasks.where((t) => t.status == TaskStatus.done).length;
          final total = projectTasks.length;

          final members = orgMembersAsync.asData?.value ?? [];

          return CustomScrollView(
            slivers: [
              // Project Info Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: AppTextStyles.headingMedium.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (project.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          project.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Status Progress Overview Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Task Progress',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  total == 0
                                      ? '0%'
                                      : '${((doneCount / total) * 100).round()}% Completed',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Segmented progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: SizedBox(
                                height: 8,
                                child: total == 0
                                    ? Container(color: AppColors.neutralContainer)
                                    : Row(
                                        children: [
                                          if (doneCount > 0)
                                            Expanded(
                                              flex: doneCount,
                                              child: Container(color: AppColors.success),
                                            ),
                                          if (reviewCount > 0)
                                            Expanded(
                                              flex: reviewCount,
                                              child: Container(color: AppColors.warning),
                                            ),
                                          if (inProgCount > 0)
                                            Expanded(
                                              flex: inProgCount,
                                              child: Container(color: AppColors.info),
                                            ),
                                          if (todoCount > 0)
                                            Expanded(
                                              flex: todoCount,
                                              child: Container(color: AppColors.neutral),
                                            ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Status Counts Breakdown
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _statusCountItem('To Do', todoCount, AppColors.neutral),
                                _statusCountItem('In Prog', inProgCount, AppColors.info),
                                _statusCountItem('Review', reviewCount, AppColors.warning),
                                _statusCountItem('Done', doneCount, AppColors.success),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tasks in Project Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Project Tasks ($total)',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      AppButton(
                        label: 'Add Task',
                        icon: Icons.add,
                        height: 36,
                        variant: AppButtonVariant.primary,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TaskFormScreen(defaultProjectId: project.id),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Tasks List
              if (projectTasks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: EmptyStateView(
                      icon: Icons.assignment_outlined,
                      title: 'No tasks in this project',
                      description: 'Add your first task to start tracking work.',
                      actionLabel: 'Add Task',
                      onAction: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TaskFormScreen(defaultProjectId: project.id),
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = projectTasks[index];
                      final assignee =
                          members.where((m) => m.id == task.assigneeId).firstOrNull;

                      return TaskCard(
                        task: task,
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
                    childCount: projectTasks.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
        loading: () => ListView(
          children: const [
            TaskCardSkeleton(),
            TaskCardSkeleton(),
          ],
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _statusCountItem(String label, int count, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
