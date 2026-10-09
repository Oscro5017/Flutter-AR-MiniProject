import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class SoftButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;
  final double? width;
  final double? height;

  const SoftButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = AppConstants.radiusSmall,
    this.width,
    this.height,
  });

  @override
  State<SoftButton> createState() => _SoftButtonState();
}

class _SoftButtonState extends State<SoftButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        width: widget.width,
        height: widget.height,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: AppColors.getShadow(context),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: widget.child,
      ),
    );
  }
}
