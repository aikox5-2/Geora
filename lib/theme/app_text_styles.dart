import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Poppins Bold 28
  static TextStyle bold28({Color color = AppColors.maroon}) {
    return GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Poppins SemiBold 18
  static TextStyle semiBold18({Color color = AppColors.ink}) {
    return GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  /// Poppins Medium 13
  static TextStyle medium13({Color color = AppColors.ink}) {
    return GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: color,
    );
  }

  /// Poppins Regular 12
  static TextStyle regular12({Color color = AppColors.muted}) {
    return GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }
}
