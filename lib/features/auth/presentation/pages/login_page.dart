import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const LoginPage({super.key, this.onToggleTheme, this.isDarkMode = true});

  void _showSuccessBottomSheet(BuildContext context, LoginState state) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark &&
        MediaQuery.of(context).size.width == 0; // Forced light theme
    final user = state.user;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXLarge),
        ),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.p24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF11141A),
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.p16),
                Text(
                  'Welcome, ${user?.name ?? 'David Sterling'}!',
                  style: AppTypography.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimens.p4),
                Text(
                  '${user?.memberTier ?? 'Elite Gold Customer'} • Authenticated',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppDimens.p16),
                Container(
                  padding: const EdgeInsets.all(AppDimens.p12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: AppDimens.borderRadiusMedium,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.card_giftcard_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppDimens.p12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$25 Chauffeur Credit Applied',
                              style: AppTypography.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primaryDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Auto-applied to your next hourly or outstation ride',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.p20),
                SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      context.read<LoginBloc>().add(const ResetLoginState());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: const Color(0xFF11141A),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimens.borderRadiusMedium,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Search Nearby Drivers',
                          style: AppTypography.labelLarge.copyWith(
                            color: const Color(0xFF11141A),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: AppDimens.p8),
                        const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Color(0xFF11141A),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark &&
        MediaQuery.of(context).size.width == 0; // Forced light theme
    final size = MediaQuery.of(context).size;

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(AppDimens.p16),
              shape: const RoundedRectangleBorder(
                borderRadius: AppDimens.borderRadiusMedium,
              ),
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white),
                  const SizedBox(width: AppDimens.p12),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state.status == LoginStatus.success) {
          _showSuccessBottomSheet(context, state);
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * 0.5, // Fixed height at top
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    // Using an image that represents searching for a driver / being driven
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?q=80&w=1000',
                    ),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                ),
                child: Container(
                  // Gradient overlay to ensure text is readable
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 60,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Icon / Logo at top (overlapping circles like reference)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE94E34), // Orange/Red
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Positioned(
                                left: 8,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF2A33A,
                                    ).withValues(alpha: 0.9), // Yellow/Orange
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Let's drive",
                        style: AppTypography.displayMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Overlapping Sheet with Glassmorphism & Animation
            Positioned(
              top: size.height * 0.4, // Glass panel starts here
              left: 0,
              right: 0,
              bottom: 0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 100 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.75,
                        ), // Light frosted glass
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        border: Border(
                          top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, -10),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: AppDimens.p24,
                          right: AppDimens.p24,
                          top: AppDimens.p32,
                          bottom: AppDimens.p32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Logo Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Find a Driver',
                                    style: AppTypography.titleLarge.copyWith(
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A1A1A),
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                // Brand Mark (Similar to the reference logo)
                                Container(
                                  height: 48,
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceElevatedDark
                                        : AppColors.inputFillLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Positioned(
                                          left: 10,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary
                                                  .withValues(alpha: 0.8),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppDimens.p24),

                            // Form Fields & Action
                            const LoginForm(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
