import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/social_auth_button.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
              child: Text(
                'OR SIGN IN WITH',
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isDark ? AppColors.dividerDark : AppColors.dividerLight,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppDimens.p20),

        // Social Sign-in Buttons Row
        Row(
          children: [
            SocialAuthButton(
              provider: SocialProvider.google,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Signing in with Google Customer Account...'),
                  ),
                );
              },
            ),
            const SizedBox(width: AppDimens.p12),
            SocialAuthButton(
              provider: SocialProvider.apple,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Signing in with Apple Customer Account...'),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: AppDimens.p28),

        // Customer Value Prop Card Banner
        Container(
          padding: const EdgeInsets.all(AppDimens.p16),
          decoration: BoxDecoration(
            gradient: isDark ? AppColors.cardGlassGradientDark : null,
            color: isDark ? null : Colors.white,
            borderRadius: AppDimens.borderRadiusLarge,
            border: Border.all(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.cardBorderLight,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_pin_circle_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppDimens.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need a Chauffeur for Your Car?',
                      style: AppTypography.labelMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Hourly, One-Way, Round-Trip & Outstation',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.p8),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('Opening Customer Registration...'),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: (isDark ? AppColors.primary : AppColors.primaryDark)
                      .withValues(alpha: 0.15),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Sign Up',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? AppColors.primary : AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimens.p20),

        // 24/7 Customer Support Helpline
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent_rounded,
              size: 16,
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            ),
            const SizedBox(width: AppDimens.p6),
            Text(
              '24/7 Customer Booking Helpline: 1-800-CAR-DRIV',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
