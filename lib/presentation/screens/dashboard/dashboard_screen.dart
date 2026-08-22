import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/task.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/notification_notifier.dart';
import '../../providers/project_notifier.dart';
import '../../providers/task_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/loading_skeleton.dart';
import '../../widgets/project_card.dart';
import '../../widgets/task_card.dart';
import '../../widgets/user_avatar.dart';
import '../notifications/notifications_screen.dart';
import '../projects/project_details_screen.dart';
import '../projects/project_form_screen.dart';
import '../tasks/task_details_screen.dart';
import '../tasks/task_form_screen.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback onNavigateToProjects;
  final VoidCallback onNavigateToTasks;

  const DashboardScreen({
    super.key,
    required this.onNavigateToProjects,
    required this.onNavigateToTasks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (authState is! Authenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    final session = authState.session;
    final projectsAsync = ref.watch(projectsNotifierProvider);
    final tasksAsync = ref.watch(tasksNotifierProvider);
    final unreadNotifsCount = ref.watch(unreadNotificationsCountProvider);
    final orgMembersAsync = ref.watch(orgMembersProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(projectsNotifierProvider.notifier).loadProjects(forceRefresh: true),
              ref.read(tasksNotifierProvider.notifier).loadTasks(forceRefresh: true),
              ref.read(notificationsNotifierProvider.notifier).loadNotifications(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // Top App Bar / Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          UserAvatar(
                            name: session.user.name,
                            avatarUrl: session.user.avatarUrl,
                            radius: 22,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, ${session.user.name.split(" ").first} 👋',
                                style: AppTextStyles.headingSmall.copyWith(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    session.organization.name,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (isDark ? AppColors.primaryLight : AppColors.primary)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      session.role.label,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Notification Bell
                      IconButton(
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 26,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                            if (unreadNotifsCount > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '$unreadNotifsCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Metrics Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: tasksAsync.when(
                    data: (tasks) {
                      final projectsCount = projectsAsync.maybeWhen(
                        data: (p) => p.length,
                        orElse: () => 0,
                      );
                      final activeCount =
                          tasks.where((t) => t.status != TaskStatus.done).length;
                      final completedCount =
                          tasks.where((t) => t.status == TaskStatus.done).length;
                      final overdueCount = tasks
                          .where((t) => DateFormatter.isOverdue(
                                t.dueDate,
                                t.status == TaskStatus.done,
                              ))
                          .length;

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context: context,
                                  title: 'Total Projects',
                                  value: '$projectsCount',
                                  icon: Icons.folder_outlined,
                                  color: AppColors.primary,
                                  onTap: onNavigateToProjects,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context: context,
                                  title: 'Active Tasks',
                                  value: '$activeCount',
                                  icon: Icons.pending_actions_rounded,
                                  color: AppColors.info,
                                  onTap: onNavigateToTasks,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  context: context,
                                  title: 'Completed',
                                  value: '$completedCount',
                                  icon: Icons.task_alt_rounded,
                                  color: AppColors.success,
                                  onTap: onNavigateToTasks,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  context: context,
                                  title: 'Overdue',
                                  value: '$overdueCount',
                                  icon: Icons.warning_amber_rounded,
                                  color: AppColors.error,
                                  onTap: onNavigateToTasks,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const Row(
                      children: [
                        Expanded(child: SkeletonBox(width: double.infinity, height: 80)),
                        SizedBox(width: 12),
                        Expanded(child: SkeletonBox(width: double.infinity, height: 80)),
                      ],
                    ),
                    error: (e, st) => const SizedBox(),
                  ),
                ),
              ),

              // Quick Actions Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Create Task',
                          icon: Icons.add_task_rounded,
                          variant: AppButtonVariant.primary,
                          height: 44,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TaskFormScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      if (session.isAdmin) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            label: 'New Project',
                            icon: Icons.create_new_folder_outlined,
                            variant: AppButtonVariant.outline,
                            height: 44,
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ProjectFormScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Recent Projects Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Projects',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: onNavigateToProjects,
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Projects List
              projectsAsync.when(
                data: (projects) {
                  if (projects.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: EmptyStateView(
                          icon: Icons.folder_open_rounded,
                          title: 'No projects yet',
                          description: 'Create your first project to get started.',
                          actionLabel: session.isAdmin ? 'Create Project' : null,
                          onAction: session.isAdmin
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const ProjectFormScreen(),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                    );
                  }

                  final displayProjects = projects.take(3).toList();
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final proj = displayProjects[index];
                        return ProjectCard(
                          project: proj,
                          canManage: session.isAdmin,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProjectDetailsScreen(projectId: proj.id),
                              ),
                            );
                          },
                        );
                      },
                      childCount: displayProjects.length,
                    ),
                  );
                },
                loading: () => SliverToBoxAdapter(
                  child: Column(
                    children: const [
                      ProjectCardSkeleton(),
                      ProjectCardSkeleton(),
                    ],
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Failed to load projects: $e'),
                  ),
                ),
              ),

              // My Tasks Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assigned to Me',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: onNavigateToTasks,
                        child: const Text('View All Tasks'),
                      ),
                    ],
                  ),
                ),
              ),

              // My Tasks List
              tasksAsync.when(
                data: (tasks) {
                  final myTasks = tasks
                      .where((t) => t.assigneeId == session.user.id)
                      .take(4)
                      .toList();

                  if (myTasks.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: EmptyStateView(
                          icon: Icons.checklist_rounded,
                          title: 'No tasks assigned',
                          description: 'You have no active tasks assigned to you.',
                        ),
                      ),
                    );
                  }

                  final members = orgMembersAsync.asData?.value ?? [];

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = myTasks[index];
                        final assignee = members.where((m) => m.id == task.assigneeId).firstOrNull;

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
                      childCount: myTasks.length,
                    ),
                  );
                },
                loading: () => SliverToBoxAdapter(
                  child: Column(
                    children: const [
                      TaskCardSkeleton(),
                      TaskCardSkeleton(),
                    ],
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Failed to load tasks: $e'),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
