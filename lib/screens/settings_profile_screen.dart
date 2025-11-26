import 'package:flutter/material.dart';
import 'package:buddyapp/services/firebase_auth_service.dart';
import 'package:buddyapp/services/theme_service.dart';
import 'package:buddyapp/services/google_auth_service.dart';

class SettingsProfileScreen extends StatefulWidget {
  const SettingsProfileScreen({super.key});

  @override
  State<SettingsProfileScreen> createState() => _SettingsProfileScreenState();
}

class _SettingsProfileScreenState extends State<SettingsProfileScreen> {
  bool _isDarkMode = false;
  int _selectedIndex = 4; // Profile tab selected
  late FirebaseAuthService _authService;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
    _loadThemePreference();
  }

  Future<void> _initializeAuth() async {
    _authService = await FirebaseAuthService.getInstance();
    _loadUserData();
  }

  void _loadThemePreference() {
    setState(() {
      _isDarkMode = ThemeService.instance.isDarkMode();
    });
  }

  Future<void> _loadUserData() async {
    final userData =
        await _authService.getUserData(_authService.currentUser?.uid ?? '');
    if (userData != null) {
      setState(() {
        _userData = userData;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Logout',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Text(
          'Are you sure you want to logout? You will need to sign in again to access your account.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Logout',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      final result = await _authService.signOut();
      if (result['success']) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (Route<dynamic> route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToHelpSupport() {
    Navigator.of(context).pushNamed('/help-support');
  }

  void _navigateToNotifications() {
    Navigator.of(context).pushNamed('/notifications');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        // Profile Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userData?['firstName'] != null &&
                                _userData?['lastName'] != null
                            ? '${_userData!['firstName']} ${_userData!['lastName']}'
                            : 'User',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userData?['email'] ?? 'user@example.com',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userData?['role'] ?? 'Team Member',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // App Settings Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'APP SETTINGS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Dark Mode Toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.dark_mode_outlined,
                              size: 20,
                              color: Theme.of(context).iconTheme.color,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Dark Mode',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          Switch(
                            value: _isDarkMode,
                            onChanged: (value) async {
                              setState(() {
                                _isDarkMode = value;
                              });
                              await ThemeService.instance.setTheme(
                                value ? ThemeMode.dark : ThemeMode.light,
                              );
                              // Show message to user
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      value
                                          ? 'Dark mode enabled'
                                          : 'Light mode enabled',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                    ),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    // Notifications
                    // InkWell(
                    //   onTap: _navigateToNotifications,
                    //   borderRadius: BorderRadius.circular(8),
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 20,
                    //       vertical: 16,
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         Container(
                    //           width: 40,
                    //           height: 40,
                    //           decoration: BoxDecoration(
                    //             color: Theme.of(context)
                    //                 .dividerColor
                    //                 .withOpacity(0.1),
                    //             borderRadius: BorderRadius.circular(8),
                    //           ),
                    //           child: Icon(
                    //             Icons.notifications_outlined,
                    //             size: 20,
                    //             color: Theme.of(context).iconTheme.color,
                    //           ),
                    //         ),
                    //         const SizedBox(width: 16),
                    //         Expanded(
                    //           child: Text(
                    //             'Notifications',
                    //             style: Theme.of(context)
                    //                 .textTheme
                    //                 .bodyMedium
                    //                 ?.copyWith(
                    //                   fontWeight: FontWeight.w500,
                    //                 ),
                    //           ),
                    //         ),
                    //         Icon(
                    //           Icons.chevron_right,
                    //           color: Theme.of(context)
                    //               .iconTheme
                    //               .color
                    //               ?.withOpacity(0.5),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // Google Drive Connection
                    ValueListenableBuilder<String?>(
                      valueListenable:
                          GoogleAuthService.instance.driveAccessTokenNotifier,
                      builder: (context, token, _) {
                        final isConnected = token != null && token.isNotEmpty;
                        return InkWell(
                          onTap: () async {
                            if (isConnected) {
                              await GoogleAuthService.instance.signOut();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Disconnected from Google Drive'),
                                  ),
                                );
                              }
                            } else {
                              final newToken = await GoogleAuthService.instance
                                  .signInForDrive();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(newToken == null
                                        ? 'Google sign-in was cancelled or failed'
                                        : 'Google Drive connected for uploads'),
                                  ),
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .dividerColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.cloud_done_outlined,
                                    size: 20,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Google Drive',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isConnected
                                            ? 'Connected for photo uploads'
                                            : 'Not connected',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  Theme.of(context).hintColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  isConnected ? 'Disconnect' : 'Connect',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Account Actions Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'ACCOUNT ACTIONS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Help & Support
                    InkWell(
                      onTap: _navigateToHelpSupport,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.help_outline,
                                size: 20,
                                color: Theme.of(context).iconTheme.color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Help & Support',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Theme.of(context)
                                  .iconTheme
                                  .color
                                  ?.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    // Log Out
                    InkWell(
                      onTap: _showLogoutDialog,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.logout,
                                size: 20,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Log Out',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
    // bottomNavigationBar: Container(
    //   decoration: BoxDecoration(
    //     color: AppColors.white,
    //     boxShadow: [
    //       BoxShadow(
    //         color: AppColors.shadow,
    //         blurRadius: 8,
    //         offset: const Offset(0, -2),
    //       ),
    //     ],
    //   ),
    //   child: SafeArea(
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 8),
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceAround,
    //         children: [
    //           _buildNavItem(Icons.home_outlined, 'Home', 0),
    //           _buildNavItem(Icons.folder_outlined, 'Projects', 1),
    //           _buildNavItem(Icons.add_circle_outline, 'Add', 2),
    //           _buildNavItem(Icons.bar_chart_outlined, 'Reports', 3),
    //           _buildNavItem(Icons.person_outline, 'Profile', 4),
    //         ],
    //       ),
    //     ),
    //   ),
    // ),
  }

  // Widget _buildNavItem(IconData icon, String label, int index) {
  //   final isSelected = _selectedIndex == index;
  //   return InkWell(
  //     onTap: () {
  //       setState(() {
  //         _selectedIndex = index;
  //       });
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: isSelected ? const Color(0xFFE3F2FD) : Colors.transparent,
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(
  //             icon,
  //             size: 24,
  //             color: isSelected ? AppColors.primary : AppColors.textTertiary,
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             label,
  //             style: AppTextStyles.labelSmall.copyWith(
  //               color: isSelected ? AppColors.primary : AppColors.textTertiary,
  //               fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
