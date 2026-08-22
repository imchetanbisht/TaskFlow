import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/debug_notifier.dart';
import '../../providers/notification_notifier.dart';
import '../../providers/theme_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/user_avatar.dart';
import '../auth/login_screen.dart';
import '../notifications/notifications_screen.dart';
import 'debug_settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final debugState = ref.watch(debugNotifierProvider);
    final unreadNotifs = ref.watch(unreadNotificationsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final session = authState.session;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                ),
              ),
              child: Row(
                children: [
                  UserAvatar(
                    name: session.user.name,
                    avatarUrl: session.user.avatarUrl,
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                session.user.name,
                                style: AppTextStyles.headingSmall.copyWith(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.primaryLight : AppColors.primary)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                session.role.label,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          session.user.email,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.business_rounded,
                              size: 14,
                              color: isDark ? AppColors.primaryLight : AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              session.organization.name,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Simulated Session & Token Flow Card
            Text(
              'Simulated Session & Token',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
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
                      Row(
                        children: [
                          const Icon(Icons.token_outlined, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Access Token Expiry', style: AppTextStyles.labelMedium),
                        ],
                      ),
                      Text(
                        DateFormatter.formatDateTime(session.accessTokenExpiresAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.security_rounded, size: 18, color: AppColors.success),
                          const SizedBox(width: 8),
                          Text('Status', style: AppTextStyles.labelMedium),
                        ],
                      ),
                      Text(
                        session.isExpired ? 'Expired (Auto-refreshing)' : 'Valid Active Session',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: session.isExpired ? AppColors.warning : AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'Simulate Manual Token Refresh',
                    icon: Icons.refresh_rounded,
                    height: 38,
                    variant: AppButtonVariant.secondary,
                    onPressed: () async {
                      await ref.read(authNotifierProvider.notifier).manualRefreshToken();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Access Token refreshed successfully')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Settings Section
            Text(
              'App Preferences',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.cardBorder,
                ),
              ),
              child: Column(
                children: [
                  // Dark Mode Switch
                  ListTile(
                    leading: Icon(
                      themeMode == ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                    title: const Text('Dark Mode'),
                    trailing: Switch(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (val) {
                        ref
                            .read(themeNotifierProvider.notifier)
                            .setTheme(val ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                  ),
                  const Divider(),
                  // Notifications Inbox
                  ListTile(
                    leading: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                    ),
                    title: const Text('Notifications Inbox'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (unreadNotifs > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$unreadNotifs new',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  // Developer / Debug Simulation Panel
                  ListTile(
                    leading: const Icon(Icons.bug_report_outlined, color: AppColors.warning),
                    title: const Text('Developer & Simulation Tools'),
                    subtitle: Text(
                      debugState.isOffline
                          ? 'Offline Mode Active'
                          : 'Simulate Offline, 404, Timeout & Delay',
                      style: AppTextStyles.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DebugSettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            AppButton(
              label: 'Log Out',
              icon: Icons.logout_rounded,
              variant: AppButtonVariant.destructive,
              height: 48,
              onPressed: () {
                ConfirmationDialog.show(
                  context: context,
                  title: 'Log out?',
                  message: 'Are you sure you want to log out of your session?',
                  confirmLabel: 'Log Out',
                  isDestructive: true,
                  onConfirm: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
