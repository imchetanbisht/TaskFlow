import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/debug_notifier.dart';
import '../../widgets/app_button.dart';

class DebugSettingsScreen extends ConsumerWidget {
  const DebugSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debugState = ref.watch(debugNotifierProvider);
    final debugNotifier = ref.read(debugNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulation & Debug Tools'),
        actions: [
          TextButton(
            onPressed: () {
              debugNotifier.reset();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulation parameters reset to default')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner explanation
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? AppColors.primaryLight : AppColors.primary).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Use these controls to simulate various error conditions, offline state, and delays for review testing.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Simulation Controls Card
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
                // Offline Mode
                SwitchListTile(
                  title: const Text('Simulate Offline Mode'),
                  subtitle: const Text('Blocks mock network calls, uses cached data'),
                  secondary: const Icon(Icons.cloud_off_rounded, color: AppColors.warning),
                  value: debugState.isOffline,
                  onChanged: (val) => debugNotifier.toggleOffline(val),
                ),
                const Divider(),

                // Network Timeout
                SwitchListTile(
                  title: const Text('Simulate Network Timeout'),
                  subtitle: const Text('Throws simulated network timeout exceptions'),
                  secondary: const Icon(Icons.timer_off_outlined, color: AppColors.error),
                  value: debugState.simulateTimeout,
                  onChanged: (val) => debugNotifier.toggleTimeout(val),
                ),
                const Divider(),

                // 404 Not Found
                SwitchListTile(
                  title: const Text('Simulate 404 Not Found'),
                  subtitle: const Text('Throws resource not found exceptions'),
                  secondary: const Icon(Icons.find_replace_rounded, color: AppColors.error),
                  value: debugState.simulateNotFound,
                  onChanged: (val) => debugNotifier.toggleNotFound(val),
                ),
                const Divider(),

                // Validation Error
                SwitchListTile(
                  title: const Text('Simulate Server Validation Error'),
                  subtitle: const Text('Throws simulated server-side validation error'),
                  secondary: const Icon(Icons.rule_folder_outlined, color: AppColors.warning),
                  value: debugState.simulateValidationError,
                  onChanged: (val) => debugNotifier.toggleValidationError(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Artificial Delay Slider Card
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
                    Text('Artificial Network Delay', style: AppTextStyles.labelMedium),
                    Text(
                      '${debugState.artificialDelayMs} ms',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDark ? AppColors.primaryLight : AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: debugState.artificialDelayMs.toDouble(),
                  min: 0,
                  max: 2000,
                  divisions: 20,
                  label: '${debugState.artificialDelayMs} ms',
                  onChanged: (val) => debugNotifier.setArtificialDelay(val.toInt()),
                ),
                Text(
                  'Adds a realistic response delay to demonstrate loading skeletons and spinners.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          AppButton(
            label: 'Reset All Parameters to Default',
            variant: AppButtonVariant.outline,
            onPressed: () {
              debugNotifier.reset();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulation parameters reset')),
              );
            },
          ),
        ],
      ),
    );
  }
}
