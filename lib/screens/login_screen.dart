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
import 'package:buddyapp/screens/signup_screen.dart';
import 'package:buddyapp/screens/reset_password_screen.dart';
import 'package:buddyapp/screens/dashboard_screen.dart';
import 'package:buddyapp/services/google_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result['success']) {
          AppHelpers.showSuccessToast(result['message']);
          Navigator.of(context)
              .pushReplacementNamed(AppConstants.dashboardRoute);
        } else {
          AppHelpers.showErrorToast(result['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        AppHelpers.showErrorToast('Login failed. Please try again.');
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _navigateToSignUp() {
    Navigator.of(context).pushNamed(AppConstants.registerRoute);
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).pushNamed(AppConstants.forgotPasswordRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // App Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 50,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 32),
              // App Title
              Text(
                'Welcome to BuddyApp',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to manage your workflow',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 48),
              // Login Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    CustomInputField(
                      label: 'Email Address',
                      hint: 'Enter your email',
                      controller: _emailController,
                      type: InputFieldType.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: AppHelpers.validateEmail,
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    CustomInputField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      type: InputFieldType.password,
                      obscureText: _obscurePassword,
                      showPasswordToggle: true,
                      textInputAction: TextInputAction.done,
                      validator: AppHelpers.validatePassword,
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Theme.of(context).hintColor,
                      ),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 16),
                    // Remember Me & Forgot Password
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember me',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.7),
                                  ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _navigateToForgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Login Button
                    CustomButton(
                      text: 'Sign In',
                      onPressed: _login,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      type: ButtonType.primary,
                      size: ButtonSize.large,
                    ),
                    const SizedBox(height: 24),
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.7),
                                  ),
                        ),
                        TextButton(
                          onPressed: _navigateToSignUp,
                          child: Text(
                            'Sign Up',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
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
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Google Sign In Button
                    CustomButton(
                      text: 'Sign in with Google',
                      onPressed: () async {
                        final token =
                            await GoogleAuthService.instance.signInForDrive();
                        if (token == null) {
                          AppHelpers.showErrorToast(
                              'Google sign-in was cancelled or failed');
                        } else {
                          AppHelpers.showSuccessToast(
                              'Google Drive connected for uploads');
                          if (mounted) {
                            Navigator.of(context).pushReplacementNamed(
                                AppConstants.dashboardRoute);
                          }
                        }
                      },
                      isFullWidth: true,
                      type: ButtonType.outline,
                      size: ButtonSize.large,
                      icon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.g_mobiledata,
                            color: Theme.of(context).colorScheme.primary,
                            size: 25,
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Terms & Privacy
                    Column(
                      children: [
                        Text(
                          'By signing in, you agree to our',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/terms');
                              },
                              child: Text(
                                'Terms & Conditions',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                            Text(
                              ' and ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).hintColor,
                                  ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed('/privacy');
                              },
                              child: Text(
                                'Privacy Policy',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
