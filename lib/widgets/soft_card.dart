import 'package:flutter/material.dart';
import 'soft_container.dart';
import '../core/constants/app_constants.dart';

class SoftCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const SoftCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SoftContainer(
        margin: margin,
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: child,
        ),
      ),
    );
  }
}
