import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class SoftContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;

  const SoftContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 20.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16.0),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }
}
