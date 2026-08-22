import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/task.dart';

class StatusChip extends StatelessWidget {
  final TaskStatus status;
  final bool isSelected;
  final VoidCallback? onTap;

  const StatusChip({
    super.key,
    required this.status,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (status) {
      case TaskStatus.todo:
        bg = AppColors.neutralContainer;
        fg = AppColors.neutralText;
        border = AppColors.cardBorder;
        break;
      case TaskStatus.inProgress:
        bg = AppColors.infoContainer;
        fg = AppColors.infoText;
        border = AppColors.info.withValues(alpha: 0.3);
        break;
      case TaskStatus.review:
        bg = AppColors.warningContainer;
        fg = AppColors.warningText;
        border = AppColors.warning.withValues(alpha: 0.3);
        break;
      case TaskStatus.done:
        bg = AppColors.successContainer;
        fg = AppColors.successText;
        border = AppColors.success.withValues(alpha: 0.3);
        break;
    }

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? fg : bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? fg : border,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
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
        borderRadius: BorderRadius.circular(20),
        child: child,
      );
    }
    return child;
  }
}
