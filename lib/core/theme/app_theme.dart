import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

/// Application theme configurations.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.black,
        secondary: AppColors.secondary,
        onSecondary: Colors.black,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: AppTypography.darkTextTheme,
      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimens.borderRadiusLarge,
          side: BorderSide(color: AppColors.cardBorderDark, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillDark,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiaryDark),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.p20, vertical: AppDimens.p16),
        border: OutlineInputBorder(
          borderRadius: AppDimens.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.inputBorderDark, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimens.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.inputBorderDark, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimens.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimens.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimens.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, AppDimens.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.borderRadiusMedium,
          ),
          textStyle: AppTypography.labelLarge,
          elevation: 2,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primaryDark,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryDark,
        onPrimary: Colors.white,
        secondary: AppColors.secondaryDark,
        onSecondary: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: AppTypography.lightTextTheme,
      cardTheme: const CardThemeData(
        color: AppColors.cardLight,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimens.borderRadiusLarge,
          side: BorderSide(color: AppColors.cardBorderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillLight,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiaryLight),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.p20, vertical: AppDimens.p16),
        border: OutlineInputBorder(
          borderRadius: AppDimens.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.inputBorderLight, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimens.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.inputBorderLight, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimens.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimens.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimens.borderRadiusMedium,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppDimens.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimens.borderRadiusMedium,
          ),
          textStyle: AppTypography.labelLarge,
          elevation: 2,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
      ),
    );
  }
}
