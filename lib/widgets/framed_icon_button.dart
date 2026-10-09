import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class FramedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final EdgeInsetsGeometry? margin;

  const FramedIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context).withValues(alpha: 0.8),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.getTextSecondary(context).withValues(alpha: 0.18),
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.getTextPrimary(context)),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}
