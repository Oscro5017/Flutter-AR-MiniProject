import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xff6C8CFF);
  static const Color secondary = Color(0xff8E6BFF);

  // Light
  static const Color lightBackground = Color(0xffeef4ff);
  static const Color lightCard = Color(0xffeef4ff);
  // Dark
  static const Color darkBackground = Color(0xff171A22);
  static const Color darkCard = Color(0xff252A36);

  static const Color success = Color(0xff4CAF50);
  static const Color error = Color(0xffE53935);

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCard
        : lightCard;
  }

  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xff303030);
  }

  static Color shadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black45
        : Colors.grey.shade300;
  }
}