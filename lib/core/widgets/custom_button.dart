import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool isOutlined;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.isOutlined = false,
    this.width,
    this.height = AppDimens.buttonHeight,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    if (widget.isOutlined) {
      return SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
              width: 1.5,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppDimens.borderRadiusMedium,
            ),
          ),
          child: _buildChild(
            context,
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      );
    }

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: AppDimens.borderRadiusMedium,
          gradient: isEnabled ? AppColors.primaryGradient : null,
          color: isEnabled
              ? null
              : (isDark ? AppColors.surfaceElevatedDark : Colors.grey.shade300),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.38),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            onHighlightChanged: (highlighted) {
              setState(() {
                _isPressed = highlighted;
              });
            },
            borderRadius: AppDimens.borderRadiusMedium,
            child: Center(
              child: _buildChild(
                context,
                isEnabled ? const Color(0xFF11141A) : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(BuildContext context, Color textColor) {
    if (widget.isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: AppDimens.p8),
        ],
        Text(
          widget.text,
          style: AppTypography.labelLarge.copyWith(
            color: textColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: AppDimens.p8),
          widget.trailingIcon!,
        ],
      ],
    );
  }
}
