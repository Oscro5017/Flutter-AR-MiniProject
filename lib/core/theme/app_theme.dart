import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
    ),
    
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
      bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBackground,
      selectedItemColor: AppColors.darkPrimary,
      unselectedItemColor: AppColors.darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF252934), // Solid dark gray
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: TextStyle(color: AppColors.darkTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      contentTextStyle: TextStyle(color: AppColors.darkTextSecondary, fontSize: 16),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
    ),
    
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
      headlineLarge: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
      headlineMedium: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
      headlineSmall: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
      titleLarge: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
      bodyLarge: const TextStyle(color: AppColors.lightTextPrimary),
      bodyMedium: const TextStyle(color: AppColors.lightTextSecondary),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
      titleTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0, // Lower elevation for cleaner look
    ),
    
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white, // Pure solid white
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: const TextStyle(color: AppColors.lightTextPrimary, fontSize: 20, fontWeight: FontWeight.bold),
      contentTextStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 16),
    ),
  );
}
