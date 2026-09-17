import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/login_event.dart';

class DriverToggleTab extends StatelessWidget {
  final LoginMode currentMode;
  final ValueChanged<LoginMode> onModeChanged;

  const DriverToggleTab({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.inputFillLight,
        borderRadius: AppDimens.borderRadiusMedium,
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 1.2,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 4) / 2;
          final isPhone = currentMode == LoginMode.phone;

          return Stack(
            children: [
              // Sliding Animated Indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                left: isPhone ? 0 : tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall + 2),
                    border: Border.all(
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.primaryDark.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Buttons Row
              Row(
                children: [
                  _buildTabItem(
                    context: context,
                    title: 'Phone Number',
                    icon: Icons.phone_android_rounded,
                    isActive: isPhone,
                    isDark: isDark,
                    onTap: () => onModeChanged(LoginMode.phone),
                  ),
                  _buildTabItem(
                    context: context,
                    title: 'Email Address',
                    icon: Icons.alternate_email_rounded,
                    isActive: !isPhone,
                    isDark: isDark,
                    onTap: () => onModeChanged(LoginMode.email),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? (isDark ? AppColors.primary : AppColors.primaryDark)
                    : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
              ),
              const SizedBox(width: AppDimens.p8),
              Text(
                title,
                style: AppTypography.labelMedium.copyWith(
                  color: isActive
                      ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
