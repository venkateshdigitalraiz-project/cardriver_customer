// ignore_for_file: avoid_print
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    final text = _phoneController.text;
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (text != digits || digits.length > 10) {
      final sanitized = digits.length > 10 ? digits.substring(0, 10) : digits;
      _phoneController.value = TextEditingValue(
        text: sanitized,
        selection: TextSelection.collapsed(offset: sanitized.length),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onRegister(BuildContext context) {
    print('==================================================================');
    print('🖱️ [REGISTER PAGE] Register Button Pressed');
    if (!_formKey.currentState!.validate()) {
      print('⚠️ [REGISTER PAGE] Form validation failed. One or more fields are invalid.');
      print('==================================================================');
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();

    if (phone.length != 10) {
      print('⚠️ [REGISTER PAGE] Form validation failed. Phone number must be exactly 10 digits.');
      print('==================================================================');
      return;
    }

    print('🚀 [REGISTER PAGE] Form valid. Dispatching RegisterSubmitted:');
    print('   - firstName : "$firstName"');
    print('   - lastName  : "$lastName"');
    print('   - email     : "$email"');
    print('   - phone     : "$phone"');
    print('   - address   : "$address"');
    print('==================================================================');

    context.read<RegisterBloc>().add(
      RegisterSubmitted(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          print('🎉 [REGISTER PAGE] UI Received RegisterStatus.success');
          context.read<RegisterBloc>().add(const ResetRegisterState());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E1E1E),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(AppDimens.p16),
              shape: const RoundedRectangleBorder(
                borderRadius: AppDimens.borderRadiusMedium,
              ),
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent),
                  const SizedBox(width: AppDimens.p12),
                  Expanded(
                    child: Text(
                      state.successMessage ?? 'Registration successful! Please sign in with your mobile number.',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
          context.pop();
        } else if (state.status == RegisterStatus.failure && state.errorMessage != null) {
          print('❌ [REGISTER PAGE] UI Received RegisterStatus.failure: ${state.errorMessage}');
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
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == RegisterStatus.loading;

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Stack(
            children: [
              // Top Image Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size.height * 0.42,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?q=80&w=1000',
                      ),
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  child: Container(
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
                      vertical: 50,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.black87,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Register",
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

              // Bottom Overlapping Sheet
              Positioned(
                top: size.height * 0.32,
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
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
                          top: AppDimens.p28,
                          bottom: AppDimens.p32,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Account',
                                style: AppTypography.titleLarge.copyWith(
                                  color: const Color(0xFF1A1A1A),
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Sign up to book professional chauffeurs for your car',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: AppDimens.p20),

                              // First Name
                              CustomTextField(
                                controller: _firstNameController,
                                label: 'First Name',
                                hintText: 'Enter your first name',
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                                validator: (val) =>
                                    Validators.validateRequired(val, 'First Name'),
                              ),
                              const SizedBox(height: AppDimens.p16),

                              // Last Name
                              CustomTextField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                hintText: 'Enter your last name',
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.person_outline_rounded),
                                validator: (val) =>
                                    Validators.validateRequired(val, 'Last Name'),
                              ),
                              const SizedBox(height: AppDimens.p16),

                              // Mobile Number
                              CustomTextField(
                                controller: _phoneController,
                                label: 'Customer Mobile Number',
                                hintText: 'Enter 10-digit phone number',
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                maxLength: 10,
                                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                validator: Validators.validatePhone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(
                                    10,
                                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                  ),
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
                                          color: AppColors.textPrimaryLight,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Container(
                                        height: 22,
                                        width: 1,
                                        margin: const EdgeInsets.symmetric(horizontal: 12),
                                        color: AppColors.inputBorderLight,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimens.p16),

                              // Email Address
                              CustomTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                hintText: 'name@example.com',
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                prefixIcon: const Icon(Icons.mail_outline_rounded),
                                validator: Validators.validateEmail,
                              ),
                              const SizedBox(height: AppDimens.p16),

                              // Address
                              CustomTextField(
                                controller: _addressController,
                                label: 'Address',
                                hintText: 'Enter your street or residential address',
                                keyboardType: TextInputType.streetAddress,
                                textInputAction: TextInputAction.done,
                                prefixIcon: const Icon(Icons.location_on_outlined),
                                validator: (val) =>
                                    Validators.validateRequired(val, 'Address'),
                              ),
                              const SizedBox(height: AppDimens.p24),

                              // Register Submit Button
                              CustomButton(
                                text: 'Register',
                                trailingIcon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 20,
                                  color: Color(0xFF11141A),
                                ),
                                isLoading: isLoading,
                                onPressed: () => _onRegister(context),
                              ),
                              const SizedBox(height: AppDimens.p20),

                              // Already have an account? Login
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already have an account? ',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.textSecondaryLight,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.pop(),
                                      child: Text(
                                        'Login',
                                        style: AppTypography.labelMedium.copyWith(
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
        );
      },
    );
  }
}
