import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/user.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/notification_notifier.dart';
import '../../providers/project_notifier.dart';
import '../../providers/task_notifier.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/priority_chip.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/user_avatar.dart';
import 'task_form_screen.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  final _commentController = TextEditingController();
  bool _isPostingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleAddComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isPostingComment = true);
    try {
      await ref
          .read(tasksNotifierProvider.notifier)
          .addComment(widget.taskId, _commentController.text.trim());
      _commentController.clear();
      ref.invalidate(taskCommentsProvider(widget.taskId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post comment: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPostingComment = false);
      }
    }
  }

  void _showAssigneePicker(TaskItem task, List<User> members) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Text(
                    'Assign Team Member',
                    style: AppTextStyles.headingSmall.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.neutralContainer,
                    child: Icon(Icons.person_off_outlined, color: AppColors.neutralText, size: 20),
                  ),
                  title: const Text('Unassigned'),
                  trailing: task.assigneeId == null
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await ref
                        .read(tasksNotifierProvider.notifier)
                        .assignTask(task.id, null);
                  },
                ),
                ...members.map((m) {
                  final isCurrent = task.assigneeId == m.id;
                  return ListTile(
                    leading: UserAvatar(name: m.name, avatarUrl: m.avatarUrl, radius: 18),
                    title: Text(m.name, style: AppTextStyles.labelLarge),
                    subtitle: Text(m.email, style: AppTextStyles.bodySmall),
                    trailing: isCurrent
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () async {
                      Navigator.of(sheetContext).pop();
                      try {
                        await ref
                            .read(tasksNotifierProvider.notifier)
                            .assignTask(task.id, m.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Assigned to ${m.name}')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                          );
                        }
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = ref.watch(taskByIdProvider(widget.taskId));
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (task == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyStateView(
          icon: Icons.search_off_rounded,
          title: 'Task not found',
          description: 'The requested task could not be found or has been deleted.',
          actionLabel: 'Back to Tasks',
          onAction: () => Navigator.of(context).pop(),
        ),
      );
    }

    final project = ref.watch(projectByIdProvider(task.projectId));
    final orgMembersAsync = ref.watch(orgMembersProvider);
    final commentsAsync = ref.watch(taskCommentsProvider(widget.taskId));
    final members = orgMembersAsync.asData?.value ?? [];
    final assignee = members.where((m) => m.id == task.assigneeId).firstOrNull;

    final isDone = task.status == TaskStatus.done;
    final isOverdue = DateFormatter.isOverdue(task.dueDate, isDone);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'edit') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
                );
              } else if (val == 'delete') {
                ConfirmationDialog.show(
                  context: context,
                  title: 'Delete task?',
                  message: 'Are you sure you want to delete "${task.title}"? This cannot be undone.',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                  onConfirm: () async {
                    try {
                      await ref.read(tasksNotifierProvider.notifier).deleteTask(task.id);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Task deleted successfully')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
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
                    Text('Edit Task'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete Task', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Chip
            if (project != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 14,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      project.name,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            // Title
            Text(
              task.title,
              style: AppTextStyles.headingMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            if (task.description.isNotEmpty) ...[
              Text(
                task.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],

            const Divider(),
            const SizedBox(height: 16),

            // Interactive Status Selector
            Text(
              'Status',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskStatus.values.map((status) {
                final isSelected = task.status == status;
                return StatusChip(
                  status: status,
                  isSelected: isSelected,
                  onTap: () {
                    ref
                        .read(tasksNotifierProvider.notifier)
                        .updateStatus(task.id, status);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Interactive Priority Selector
            Text(
              'Priority',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskPriority.values.map((priority) {
                final isSelected = task.priority == priority;
                return PriorityChip(
                  priority: priority,
                  isSelected: isSelected,
                  onTap: () {
                    ref
                        .read(tasksNotifierProvider.notifier)
                        .updatePriority(task.id, priority);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Assignee & Due Date Row
            Row(
              children: [
                // Assignee Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                      ),
                    ),
                    child: InkWell(
                      onTap: () => _showAssigneePicker(task, members),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assignee',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              UserAvatar(
                                name: assignee?.name,
                                avatarUrl: assignee?.avatarUrl,
                                radius: 14,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  assignee?.name ?? 'Unassigned',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down_rounded,
                                size: 20,
                                color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Due Date Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOverdue
                            ? AppColors.error
                            : (isDark ? AppColors.darkCardBorder : AppColors.cardBorder),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due Date',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: isOverdue ? AppColors.error : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                DateFormatter.formatDate(task.dueDate),
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: isOverdue
                                      ? AppColors.error
                                      : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                  fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Comments Section
            Text(
              'Activity & Comments',
              style: AppTextStyles.headingSmall.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Add Comment Field
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    hint: 'Write a comment...',
                    controller: _commentController,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: _isPostingComment
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  onPressed: _isPostingComment ? null : _handleAddComment,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Comments List
            commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No comments yet. Start the conversation!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final author =
                        members.where((m) => m.id == comment.authorId).firstOrNull;

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
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
                              Row(
                                children: [
                                  UserAvatar(
                                    name: author?.name,
                                    avatarUrl: author?.avatarUrl,
                                    radius: 12,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    author?.name ?? 'Team Member',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                DateFormatter.timeAgo(comment.createdAt),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            comment.body,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Failed to load comments: $err'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
