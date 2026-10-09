import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.title,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected 
              ? AppColors.interactive(context).withValues(alpha: 0.12)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: selected 
              ? Border.all(color: AppColors.interactive(context).withValues(alpha: 0.25))
              : Border.all(color: AppColors.getTextSecondary(context).withValues(alpha: 0.08)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? AppColors.interactive(context) : AppColors.textSecondary(context),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
