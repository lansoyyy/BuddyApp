import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:buddyapp/utils/app_text_styles.dart';
import 'package:buddyapp/utils/app_constants.dart';
import 'package:buddyapp/utils/app_helpers.dart';
import 'package:buddyapp/widgets/custom_button.dart';
import 'package:buddyapp/widgets/custom_input_field.dart';
import 'package:buddyapp/services/firebase_auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  late FirebaseAuthService _authService;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _authService = await FirebaseAuthService.getInstance();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await _authService.resetPassword(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          AppHelpers.showSuccessToast(result['message']);
          Navigator.of(context).pop();
        } else {
          AppHelpers.showErrorToast(result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        AppHelpers.showErrorToast('Password reset failed. Please try again.');
      }
    }
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: _navigateBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Reset Password Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.lock_reset,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Reset Password',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Reset Password Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    CustomInputField(
                      label: 'Email Address',
                      hint: 'Enter your email address',
                      controller: _emailController,
                      type: InputFieldType.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: AppHelpers.validateEmail,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.textTertiary,
                      ),
                      onSubmitted: (_) => _resetPassword(),
                    ),
                    const SizedBox(height: 32),
                    // Reset Password Button
                    CustomButton(
                      text: 'Send Reset Link',
                      onPressed: _resetPassword,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      type: ButtonType.primary,
                      size: ButtonSize.large,
                    ),
                    const SizedBox(height: 24),
                    // Back to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remember your password? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateBack,
                          child: Text(
                            'Sign In',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Help Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.grey200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Need Help?',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'If you don\'t receive the email within a few minutes, please check your spam folder or contact support.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              // TODO: Implement contact support
                              AppHelpers.showErrorToast(
                                  'Contact support coming soon');
                            },
                            child: Text(
                              'Contact Support',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
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
        ),
      ),
    );
  }
}
