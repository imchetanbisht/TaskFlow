import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/task.dart';

class PriorityChip extends StatelessWidget {
  final TaskPriority priority;
  final bool isSelected;
  final VoidCallback? onTap;

  const PriorityChip({
    super.key,
    required this.priority,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (priority) {
      case TaskPriority.low:
        bg = AppColors.neutralContainer;
        fg = AppColors.neutralText;
        icon = Icons.keyboard_arrow_down_rounded;
        break;
      case TaskPriority.medium:
        bg = AppColors.warningContainer;
        fg = AppColors.warningText;
        icon = Icons.remove_rounded;
        break;
      case TaskPriority.high:
        bg = AppColors.errorContainer;
        fg = AppColors.errorText;
        icon = Icons.keyboard_arrow_up_rounded;
        break;
      case TaskPriority.urgent:
        bg = AppColors.errorContainer;
        fg = AppColors.error;
        icon = Icons.keyboard_double_arrow_up_rounded;
        break;
    }

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? fg : bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? fg : fg.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isSelected ? Colors.white : fg,
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? Colors.white : fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: child,
      );
    }
    return child;
  }
}
