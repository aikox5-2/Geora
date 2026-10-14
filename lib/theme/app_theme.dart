import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        secondary: AppColors.cream,
        onSecondary: AppColors.ink,
        error: Colors.red,
        onError: AppColors.white,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
      ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.bold28(),
        headlineMedium: AppTextStyles.semiBold18(),
        bodyMedium: AppTextStyles.medium13(),
        bodySmall: AppTextStyles.regular12(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.semiBold18(color: AppColors.white),
      ),
    );
  }
}
