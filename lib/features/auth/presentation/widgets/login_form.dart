import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  void _onSubmit(LoginState state) {
    String? errorMsg;
    if (state.mode == LoginMode.phone) {
      errorMsg = Validators.validatePhone(_phoneController.text.trim());
    } else {
      errorMsg = Validators.validateEmail(_emailController.text.trim());
    }
    
    if (state.isOtpSent) {
      errorMsg ??= Validators.validateOtp(_passwordController.text);
    }

    if (errorMsg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  errorMsg,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFD32F2F), // Premium soft red
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(
            bottom: 32, 
            left: 24, 
            right: 24,
          ),
        ),
      );
      return;
    }

    final contact = state.mode == LoginMode.phone 
        ? _phoneController.text.trim() 
        : _emailController.text.trim();

    if (!state.isOtpSent) {
      context.read<LoginBloc>().add(SendOtpRequested(contact: contact));
    } else {
      context.read<LoginBloc>().add(
        VerifyOtpSubmitted(
          contact: contact,
          otp: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark && MediaQuery.of(context).size.width == 0; // Forced light theme

    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        final isLoading = state.status == LoginStatus.loading;

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phone or Email Input Field
              if (state.mode == LoginMode.phone) ...[
                CustomTextField(
                  controller: _phoneController,
                  label: 'Customer Mobile Number',
                  hintText: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enabled: !state.isOtpSent,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  prefixIcon: Container(
                    padding: const EdgeInsets.only(
                      left: AppDimens.p12,
                      right: AppDimens.p8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 4),
                        Text(
                          '+91',
                          style: AppTypography.labelMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          height: 22,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: isDark
                              ? AppColors.inputBorderDark
                              : AppColors.inputBorderLight,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                CustomTextField(
                  controller: _emailController,
                  label: 'Customer Email Address',
                  hintText: 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !state.isOtpSent,
                  prefixIcon: const Icon(Icons.mail_outline_rounded),
                ),
              ],

              const SizedBox(height: AppDimens.p16),

              if (state.isOtpSent) ...[
                // OTP Input Field
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                  child: Text(
                    'Enter 4-Digit OTP',
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Pinput(
                  controller: _passwordController,
                  length: 4,
                  onSubmitted: (_) => _onSubmit(state),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  defaultPinTheme: PinTheme(
                    width: 64,
                    height: 64,
                    textStyle: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w700),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.inputFillDark : Colors.white,
                      border: Border.all(
                        color: isDark ? AppColors.inputBorderDark : AppColors.inputBorderLight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 64,
                    height: 64,
                    textStyle: const TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.w700),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceElevatedDark : Colors.white,
                      border: Border.all(
                        color: isDark ? AppColors.primary : AppColors.primaryDark, 
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? AppColors.primary : AppColors.primaryDark).withValues(alpha: 0.15),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppDimens.p12),

              // Remember Me & Forgot Password Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      context.read<LoginBloc>().add(const ToggleRememberMe());
                    },
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: Checkbox(
                              value: state.rememberMe,
                              onChanged: (_) {
                                context.read<LoginBloc>().add(
                                  const ToggleRememberMe(),
                                );
                              },
                              activeColor: AppColors.primary,
                              checkColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimens.p8),
                          Text(
                            'Keep me signed in',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (state.isOtpSent)
                    TextButton(
                      onPressed: () {
                        context.read<LoginBloc>().add(
                          SendOtpRequested(
                            contact: state.mode == LoginMode.phone 
                                ? _phoneController.text.trim() 
                                : _emailController.text.trim()
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'A new OTP has been sent.',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF1E1E1E), // Premium dark grey
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.only(
                              bottom: 32, 
                              left: 24, 
                              right: 24,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Resend OTP',
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.primary
                              : AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppDimens.p16),

              // Primary Action Submit Button for Customer
              CustomButton(
                text: state.isOtpSent ? 'Verify OTP & Sign In' : 'Send OTP',
                trailingIcon: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: Color(0xFF11141A),
                ),
                isLoading: isLoading,
                onPressed: () => _onSubmit(state),
              ),
            ],
          ),
        );
      },
    );
  }
}
