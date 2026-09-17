import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Badges Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Customer Chauffeur Emblem
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFFFD54F),
                    Color(0xFFFF8F00),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF0F131A) : Colors.white,
                  ),
                  child: Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                      child: const Icon(
                        Icons.airline_seat_recline_extra_rounded,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppDimens.p12),

            // Live Drivers Available & Trust Badge
            Flexible(
              child: Wrap(
                spacing: AppDimens.p8,
                runSpacing: AppDimens.p6,
                alignment: WrapAlignment.end,
                children: [
                  // Available Drivers Count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p10,
                      vertical: AppDimens.p6,
                    ),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.15),
                      borderRadius: AppDimens.borderRadiusLarge,
                      border: Border.all(
                        color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.near_me_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '150+ NEARBY',
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Verified badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p10,
                      vertical: AppDimens.p6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: AppDimens.borderRadiusLarge,
                      border: Border.all(
                        color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'VERIFIED',
                          style: AppTypography.labelSmall.copyWith(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimens.p24),

        // Welcome Headline for Customer
        Text(
          'Hire a Driver for Your Car',
          style: AppTypography.displayLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: AppDimens.p8),

        // Customer Subtitle
        Text(
          'Book background-verified professional drivers by the hour, day, or for outstation road trips.',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
