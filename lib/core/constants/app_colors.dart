import 'package:flutter/material.dart';

class AppColors {
  // Brand & Common Colors
  static const Color primary = Color(0xFF0084FF);
  static const Color darkPrimary = Color(0xFF63A8E8);
  static const Color secondary = Color(0xFF2B303B);
  static const Color arButton = Color(0xFFC4D1FF);
  static const Color rating = Color(0xFFFFB100);
  static const Color error = Color(0xFFFF4D4D);
  static const Color soldBadge = Color(0xFF2B303B);
  static const Color soldText = Color(0xFF4D9FFF);

  // Dark Palette
  static const Color darkBackground = Color(0xFF202631);
  static const Color darkSurface = Color(0xCC1E212A);
  static const Color darkCard = Color(0xCC252934);
  static const Color darkTextPrimary = Color(0xFFDDE2EA);
  static const Color darkTextSecondary = Color(0xFFA4ACB8);

  // Light Palette
  static const Color lightBackground = Color(0xFFEEF1F7);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Color(0xCBFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1C22);
  static const Color lightTextSecondary = Color(0xFF6C707A);

  // Gradient Palette
  static const LinearGradient lightGradient = LinearGradient(
      colors: [Color(0xFFC0E5F7), Color(0xFFD6C8F2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight
  );

  static const LinearGradient darkGradient = LinearGradient(
      colors: [Color(0xFF2B3D48), Color(0xFF3E384F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight
  );

  // Dynamic Methods (Context-based)
  static Color background(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;
  static Color surface(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkSurface : lightSurface;
  static Color card(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  static Color textPrimary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  static Color interactive(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkPrimary : primary;
  
  // Aliases for compatibility
  static Color getBackground(BuildContext context) => background(context);
  static Color getSurface(BuildContext context) => surface(context);
  static Color getCard(BuildContext context) => card(context);
  static Color getTextPrimary(BuildContext context) => textPrimary(context);
  static Color getTextSecondary(BuildContext context) => textSecondary(context);

  static Decoration backgroundDecoration(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return const BoxDecoration(gradient: darkGradient);
    }
    return const BoxDecoration(gradient: lightGradient);
  }

  static Color getShadow(BuildContext context) => Theme.of(context).brightness == Brightness.dark 
      ? Colors.black.withValues(alpha: 0.4) 
      : Colors.black.withValues(alpha: 0.08);

  static List<BoxShadow> neumorphicShadow(BuildContext context) {
    return [
      BoxShadow(
        color: getShadow(context),
        offset: const Offset(0, 4),
        blurRadius: 10,
      ),
    ];
  }
}
