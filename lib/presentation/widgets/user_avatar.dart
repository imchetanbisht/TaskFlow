import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class UserAvatar extends StatelessWidget {
  final String? name;
  final String? avatarUrl;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.name,
    this.avatarUrl,
    this.radius = 18,
    this.onTap,
  });

  String _getInitials(String? text) {
    if (text == null || text.trim().isEmpty) return '?';
    final parts = text.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return text.substring(0, text.length > 1 ? 2 : 1).toUpperCase();
  }

  Color _getBgColor(String? text) {
    if (text == null || text.isEmpty) return AppColors.primary;
    final hash = text.codeUnits.fold(0, (prev, elem) => prev + elem);
    final colors = [
      const Color(0xFF4F46E5), // Indigo
      const Color(0xFF0EA5E9), // Sky
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
      const Color(0xFF14B8A6), // Teal
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final bgColor = _getBgColor(name);

    Widget avatarWidget = CircleAvatar(
      radius: radius,
      backgroundColor: bgColor.withValues(alpha: 0.15),
      child: Text(
        initials,
        style: AppTextStyles.labelMedium.copyWith(
          color: bgColor,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.75,
        ),
      ),
    );

    if (onTap != null) {
      avatarWidget = GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}
