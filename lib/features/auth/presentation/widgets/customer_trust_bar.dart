import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';

/// A simple, responsive trust indicator bar for the customer screen.
class CustomerTrustBar extends StatelessWidget {
  const CustomerTrustBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.p10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSimpleItem(
            icon: Icons.star_rounded,
            iconColor: AppColors.primary,
            title: '4.95 Rating',
            isDark: isDark,
          ),
          _buildSimpleItem(
            icon: Icons.verified_user_rounded,
            iconColor: AppColors.success,
            title: 'Verified Drivers',
            isDark: isDark,
          ),
          _buildSimpleItem(
            icon: Icons.security_rounded,
            iconColor: AppColors.secondary,
            title: 'Insured Rides',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDark,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
