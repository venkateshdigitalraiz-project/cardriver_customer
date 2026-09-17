import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark && MediaQuery.of(context).size.width == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: AppTypography.labelMedium.copyWith(
                  color: _isFocused
                      ? (isDark ? AppColors.primary : AppColors.primaryDark)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_isFocused) ...[
                const SizedBox(width: 6),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primary : AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppDimens.p8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: AppDimens.borderRadiusMedium,
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.18),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            inputFormatters: widget.inputFormatters,
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark
                  ? (_isFocused ? AppColors.surfaceElevatedDark : AppColors.inputFillDark)
                  : (_isFocused ? Colors.white : AppColors.inputFillLight),
              hintText: widget.hintText,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p16,
                vertical: AppDimens.p16,
              ),
              border: OutlineInputBorder(
                borderRadius: AppDimens.borderRadiusMedium,
                borderSide: BorderSide(
                  color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppDimens.borderRadiusMedium,
                borderSide: BorderSide(
                  color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppDimens.borderRadiusMedium,
                borderSide: BorderSide(
                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppDimens.borderRadiusMedium,
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: AppDimens.borderRadiusMedium,
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.8,
                ),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: _isFocused
                            ? (isDark ? AppColors.primary : AppColors.primaryDark)
                            : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                        size: 20,
                      ),
                      child: widget.prefixIcon!,
                    )
                  : null,
              prefix: widget.prefix,
              suffixIcon: widget.suffixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: _isFocused
                            ? (isDark ? AppColors.primary : AppColors.primaryDark)
                            : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                        size: 20,
                      ),
                      child: widget.suffixIcon!,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
