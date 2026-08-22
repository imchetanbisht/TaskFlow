import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/notification_notifier.dart';
import '../../widgets/empty_state_view.dart';
import '../tasks/task_details_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyStateView(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications',
              description: "You're all caught up! No new notifications.",
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final notif = notifications[index];

              return Card(
                color: notif.read
                    ? (isDark ? AppColors.darkSurface : Colors.white)
                    : (isDark
                        ? AppColors.primaryDark.withValues(alpha: 0.25)
                        : AppColors.primaryContainer.withValues(alpha: 0.6)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primaryLight : AppColors.primary)
                          .withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.task_alt_rounded,
                      size: 20,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                  ),
                  title: Text(
                    notif.message,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontWeight: notif.read ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      DateFormatter.timeAgo(notif.createdAt),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  trailing: notif.read
                      ? null
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                  onTap: () async {
                    if (!notif.read) {
                      await ref
                          .read(notificationsNotifierProvider.notifier)
                          .markAsRead(notif.id);
                    }
                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TaskDetailsScreen(taskId: notif.taskId),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading notifications: $err')),
      ),
    );
  }
}
