import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual tokens – Section 6.1
class AppColors {
  static const nearBlack = Color(0xFF0B0E14);
  static const glass = Color(0x1AFFFFFF); // ~10% white
  static const accentCyan = Color(0xFF3DD6F5);
  static const successGreen = Color(0xFF3EE08F);
  static const warningAmber = Color(0xFFFFB020);
  static const errorRed = Color(0xFFFF5A5F);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xB3FFFFFF);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.nearBlack,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentCyan,
        secondary: AppColors.successGreen,
        surface: AppColors.nearBlack,
        error: AppColors.errorRed,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentCyan,
          foregroundColor: AppColors.nearBlack,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentCyan,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.accentCyan),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.glass,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
    );
  }
}
