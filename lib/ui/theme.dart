import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual tokens – dark (camera overlay) + white (lists, units, results)
class AppColors {
  // Dark (over camera)
  static const nearBlack = Color(0xFF0B0E14);
  static const glass = Color(0x1AFFFFFF);
  static const accentCyan = Color(0xFF3DD6F5);
  static const successGreen = Color(0xFF3EE08F);
  static const warningAmber = Color(0xFFFFB020);
  static const errorRed = Color(0xFFFF5A5F);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xB3FFFFFF);

  // White surfaces (units, history, settings, results)
  static const white = Color(0xFFFFFFFF);
  static const offWhite = Color(0xFFF5F7FA);
  static const cardWhite = Color(0xFFFFFFFF);
  static const textOnWhite = Color(0xFF0B0E14);
  static const textMutedOnWhite = Color(0xFF5A6570);
  static const borderOnWhite = Color(0xFFE2E8F0);
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
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// White background theme for units, history, settings, result sheets.
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.offWhite,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0BB4D4),
        secondary: AppColors.successGreen,
        surface: AppColors.white,
        error: AppColors.errorRed,
        onSurface: AppColors.textOnWhite,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textOnWhite,
        displayColor: AppColors.textOnWhite,
      ),
      cardTheme: CardTheme(
        color: AppColors.cardWhite,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
