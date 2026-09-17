import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

enum SocialProvider { google, apple }

class SocialAuthButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;

  const SocialAuthButton({
    super.key,
    required this.provider,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = provider == SocialProvider.google ? 'Google' : 'Apple';
    final icon = provider == SocialProvider.google ? Icons.g_mobiledata_rounded : Icons.apple;

    return Expanded(
      child: SizedBox(
        height: AppDimens.socialButtonHeight,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            side: BorderSide(
              color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
              width: 1.2,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppDimens.borderRadiusMedium,
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.p12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: provider == SocialProvider.google ? 26 : 22,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              const SizedBox(width: AppDimens.p8),
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
