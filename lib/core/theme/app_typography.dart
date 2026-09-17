import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography scales for driver application.
class AppTypography {
  AppTypography._();

  // Primary font family: Outfit for headers, Plus Jakarta Sans for body
  static TextStyle get displayLarge => GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get titleLarge => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle get titleMedium => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  // TextTheme helper for Dark Theme
  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: displayLarge.copyWith(color: AppColors.textPrimaryDark),
        displayMedium: displayMedium.copyWith(color: AppColors.textPrimaryDark),
        titleLarge: titleLarge.copyWith(color: AppColors.textPrimaryDark),
        titleMedium: titleMedium.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        bodySmall: bodySmall.copyWith(color: AppColors.textTertiaryDark),
        labelLarge: labelLarge.copyWith(color: AppColors.textPrimaryDark),
        labelMedium: labelMedium.copyWith(color: AppColors.textSecondaryDark),
        labelSmall: labelSmall.copyWith(color: AppColors.textTertiaryDark),
      );

  // TextTheme helper for Light Theme
  static TextTheme get lightTextTheme => TextTheme(
        displayLarge: displayLarge.copyWith(color: AppColors.textPrimaryLight),
        displayMedium: displayMedium.copyWith(color: AppColors.textPrimaryLight),
        titleLarge: titleLarge.copyWith(color: AppColors.textPrimaryLight),
        titleMedium: titleMedium.copyWith(color: AppColors.textPrimaryLight),
        bodyLarge: bodyLarge.copyWith(color: AppColors.textPrimaryLight),
        bodyMedium: bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        bodySmall: bodySmall.copyWith(color: AppColors.textTertiaryLight),
        labelLarge: labelLarge.copyWith(color: AppColors.textPrimaryLight),
        labelMedium: labelMedium.copyWith(color: AppColors.textSecondaryLight),
        labelSmall: labelSmall.copyWith(color: AppColors.textTertiaryLight),
      );
}
