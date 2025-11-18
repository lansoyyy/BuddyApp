import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buddyapp/utils/app_colors.dart';
import 'package:buddyapp/utils/app_text_styles.dart';
import 'package:buddyapp/utils/app_constants.dart';
import 'package:buddyapp/utils/app_helpers.dart';
import 'package:buddyapp/widgets/custom_button.dart';
import 'package:buddyapp/widgets/custom_input_field.dart';
import 'package:buddyapp/widgets/loading_widget.dart';
import 'package:buddyapp/services/firebase_auth_service.dart';
import 'package:buddyapp/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      AppHelpers.showErrorToast('Please agree to the Terms & Conditions');
      return;
    }

    if (!_agreeToPrivacy) {
      AppHelpers.showErrorToast('Please agree to the Privacy Policy');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Split the full name into first and last name
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final result = await _authService.signUp(
        agreeToTerms: _agreeToTerms,
        agreeToPrivacy: _agreeToPrivacy,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: firstName,
        lastName: lastName,
        phone: '', // Optional - can be added later
        role: 'technician', // Default role
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          AppHelpers.showSuccessToast(result['message']);
          Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
        } else {
          AppHelpers.showErrorToast(result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        AppHelpers.showErrorToast('Registration failed. Please try again.');
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
  }

  void _showTermsAndConditions() {
    Navigator.of(context).pushNamed('/terms');
  }

  void _showPrivacyPolicy() {
    Navigator.of(context).pushNamed('/privacy');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // App Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 24),
              // App Title
              Text(
                'Create Account',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join BuddyApp to manage your workflow efficiently',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Signup Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name Field
                    CustomInputField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      controller: _nameController,
                      type: InputFieldType.text,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: AppHelpers.validateName,
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email Field
                    CustomInputField(
                      label: 'Email Address',
                      hint: 'Enter your email',
                      controller: _emailController,
                      type: InputFieldType.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: AppHelpers.validateEmail,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    CustomInputField(
                      label: 'Password',
                      hint: 'Create a strong password',
                      controller: _passwordController,
                      type: InputFieldType.password,
                      obscureText: _obscurePassword,
                      showPasswordToggle: true,
                      textInputAction: TextInputAction.next,
                      validator: AppHelpers.validatePassword,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Confirm Password Field
                    CustomInputField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      controller: _confirmPasswordController,
                      type: InputFieldType.password,
                      obscureText: _obscureConfirmPassword,
                      showPasswordToggle: true,
                      textInputAction: TextInputAction.done,
                      validator: _validateConfirmPassword,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textTertiary,
                      ),
                      onSubmitted: (_) => _signup(),
                    ),
                    const SizedBox(height: 24),
                    // Terms and Privacy Checkboxes
                    Column(
                      children: [
                        // Terms Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _agreeToTerms,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToTerms = value ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _agreeToTerms = !_agreeToTerms;
                                  });
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: _showTermsAndConditions,
                                          child: Text(
                                            'Terms & Conditions',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Privacy Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _agreeToPrivacy,
                              onChanged: (value) {
                                setState(() {
                                  _agreeToPrivacy = value ?? false;
                                });
                              },
                              activeColor: AppColors.primary,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _agreeToPrivacy = !_agreeToPrivacy;
                                  });
                                },
                                child: Text.rich(
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    children: [
                                      WidgetSpan(
                                        child: GestureDetector(
                                          onTap: _showPrivacyPolicy,
                                          child: Text(
                                            'Privacy Policy',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Signup Button
                    CustomButton(
                      text: 'Create Account',
                      onPressed: _signup,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      type: ButtonType.primary,
                      size: ButtonSize.large,
                    ),
                    const SizedBox(height: 24),
                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: _navigateToLogin,
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
                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Google Sign Up Button
                    CustomButton(
                      text: 'Sign up with Google',
                      onPressed: () {
                        // TODO: Implement Google Sign-Up
                        AppHelpers.showErrorToast('Google Sign-Up coming soon');
                      },
                      isFullWidth: true,
                      type: ButtonType.outline,
                      size: ButtonSize.large,
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/google_logo.png',
                            width: 20,
                            height: 20,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.error, size: 20);
                            },
                          ),
                          const SizedBox(width: 12),
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
