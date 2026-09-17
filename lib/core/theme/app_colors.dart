import 'package:flutter/material.dart';

/// Luxury Automotive & Driver Partner Color System.
class AppColors {
  AppColors._();

  // Primary Brand Accents (Luxury Amber Gold & Cyber Yellow)
  static const Color primary = Color(0xFFFFB800);
  static const Color primaryDark = Color(0xFFE69500);
  static const Color primaryLight = Color(0xFFFFCC33);
  static const Color primaryGlow = Color(0x55FFB800);
  static const Color gold = Color(0xFFFFD700);

  // High-Tech Accents (Neon Electric Cyan & Deep Sapphire)
  static const Color secondary = Color(0xFF00E5FF);
  static const Color secondaryDark = Color(0xFF0091EA);
  static const Color cyanGlow = Color(0x4400E5FF);
  static const Color surgeOrange = Color(0xFFFF5722);

  // Ultra-Dark Cockpit & Obsidian Neutral Colors
  static const Color backgroundDark = Color(0xFF0B0E14);
  static const Color surfaceDark = Color(0xFF131822);
  static const Color surfaceElevatedDark = Color(0xFF1A212E);
  static const Color cardDark = Color(0xFF161D29);
  static const Color cardBorderDark = Color(0xFF263347);
  static const Color glassFillDark = Color(0xCC131924);
  static const Color glassBorderDark = Color(0x33FFFFFF);
  static const Color inputFillDark = Color(0xFF0F141D);
  static const Color inputBorderDark = Color(0xFF222C3D);
  static const Color dividerDark = Color(0xFF1E2838);

  // Modern Clean Light Mode
  static const Color backgroundLight = Color(0xFFF4F7FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF0F4F9);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFE2E8F0);
  static const Color glassFillLight = Color(0xEEFFFFFF);
  static const Color glassBorderLight = Color(0x40000000);
  static const Color inputFillLight = Color(0xFFF8FAFC);
  static const Color inputBorderLight = Color(0xFFD9E2EC);
  static const Color dividerLight = Color(0xFFE5EBF2);

  // Typography Tokens
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color textDisabledDark = Color(0xFF334155);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textDisabledLight = Color(0xFFCBD5E1);

  // State & Status
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFFF3366);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF38BDF8);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFC72C), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryMetallicGradient = LinearGradient(
    colors: [Color(0xFF2E384D), Color(0xFF141923)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlassGradientDark = LinearGradient(
    colors: [Color(0xEE1E2638), Color(0xDD121722)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient badgeGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF6D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surgeBadgeGradient = LinearGradient(
    colors: [Color(0xFFFF5722), Color(0xFFFF9100)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
