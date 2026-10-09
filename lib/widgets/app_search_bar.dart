import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;

  const AppSearchBar({
    super.key,
    this.hint = "Search furniture...",
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.getTextSecondary(context), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppColors.getTextSecondary(context)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
