import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/user.dart';
import 'priority_chip.dart';
import 'status_chip.dart';
import 'user_avatar.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final String? projectName;
  final User? assignee;
  final VoidCallback onTap;
  final ValueChanged<TaskStatus>? onStatusChanged;

  const TaskCard({
    super.key,
    required this.task,
    this.projectName,
    this.assignee,
    required this.onTap,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDone = task.status == TaskStatus.done;
    final isOverdue = DateFormatter.isOverdue(task.dueDate, isDone);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top chips: Status + Priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusChip(
                    status: task.status,
                    onTap: onStatusChanged != null
                        ? () {
                            final next = task.status == TaskStatus.todo
                                ? TaskStatus.inProgress
                                : task.status == TaskStatus.inProgress
                                    ? TaskStatus.review
                                    : task.status == TaskStatus.review
                                        ? TaskStatus.done
                                        : TaskStatus.todo;
                            onStatusChanged!(next);
                          }
                        : null,
                  ),
                  PriorityChip(priority: task.priority),
                ],
              ),
              const SizedBox(height: 10),
              // Title
              Text(
                task.title,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              // Bottom Row: Due date + Assignee
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Due date / Overdue
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: isOverdue
                            ? AppColors.error
                            : (isDark ? AppColors.darkTextMuted : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatDate(task.dueDate),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isOverdue
                              ? AppColors.error
                              : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                          fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'OVERDUE',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.error,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Assignee Avatar / Name
                  if (assignee != null)
                    Row(
                      children: [
                        UserAvatar(
                          name: assignee!.name,
                          avatarUrl: assignee!.avatarUrl,
                          radius: 12,
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 100),
                          child: Text(
                            assignee!.name,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Unassigned',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        fontStyle: FontStyle.italic,
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
