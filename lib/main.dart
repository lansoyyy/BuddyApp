import 'package:buddyapp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:buddyapp/utils/app_theme.dart';
import 'package:buddyapp/utils/app_constants.dart';
import 'package:buddyapp/screens/login_screen.dart';
import 'package:buddyapp/screens/signup_screen.dart';
import 'package:buddyapp/screens/reset_password_screen.dart';
import 'package:buddyapp/screens/terms_screen.dart';
import 'package:buddyapp/screens/privacy_screen.dart';
import 'package:buddyapp/screens/dashboard_screen.dart';
import 'package:buddyapp/screens/help_support_screen.dart';
import 'package:buddyapp/screens/notifications_screen.dart';
import 'package:buddyapp/services/firebase_auth_service.dart';
import 'package:buddyapp/services/storage_service.dart';
import 'package:buddyapp/services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'shopbuddy-e017c',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize theme service
  await ThemeService.instance.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: AppConstants.isDebugModeEnabled,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const AuthWrapper(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/forgot-password': (context) => const ResetPasswordScreen(),
            '/terms': (context) => const TermsScreen(),
            '/privacy': (context) => const PrivacyScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/help-support': (context) => const HelpSupportScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/register': (context) => const SignupScreen(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Initialize services
      final authService = await FirebaseAuthService.getInstance();
      final storageService = await StorageService.getInstance();

      // Check if user is authenticated in Firebase
      final currentUser = authService.currentUser;

      // Also check if we have user data stored locally
      final hasUserData = storageService.hasUserData();

      if (currentUser != null && hasUserData) {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      // If there's any error, default to login screen
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 32,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'BuddyApp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1976D2),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
              ),
            ],
          ),
        ),
      );
    }

    return _isAuthenticated ? const DashboardScreen() : const LoginScreen();
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'BuddyApp',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Setup complete. Ready for screen development.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
