import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:buddyapp/services/firebase_auth_service.dart';
import 'package:buddyapp/services/theme_service.dart';
import 'package:buddyapp/services/google_auth_service.dart';
import 'package:buddyapp/services/storage_service.dart';

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
  bool _wmShowStatus = true;
  bool _wmShowTitle = true;
  bool _wmShowDateTime = true;
  bool _wmShowLocation = true;
  bool _wmShowWorkorder = true;

  final TextEditingController _driveWorkorderRootPathController =
      TextEditingController(text: 'Jobs');
  final TextEditingController _driveFolderTemplateController =
      TextEditingController(
          text: 'Jobs/{workorderNumber}/Photos/{processStage}');
  final TextEditingController _fileNameTemplateController =
      TextEditingController(
          text: '{component}_Photo{photoNumber}_{initials}.jpg');
  final TextEditingController _watermarkTitleTemplateController =
      TextEditingController(text: '{fileName}');

  double _watermarkBackgroundOpacity = 1.0;
  double _watermarkLogoScale = 0.25;
  int _watermarkFontSize = 24;
  int _watermarkTextColor = 0xFFFFFFFF;
  bool _watermarkShowLogo = false;
  String _watermarkLogoPath = '';

  @override
  void initState() {
    super.initState();
    _initializeAuth();
    _loadThemePreference();
    _loadWatermarkSettings();
    _loadCustomizationSettings();
  }

  @override
  void dispose() {
    _driveWorkorderRootPathController.dispose();
    _driveFolderTemplateController.dispose();
    _fileNameTemplateController.dispose();
    _watermarkTitleTemplateController.dispose();
    super.dispose();
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

  Future<void> _loadWatermarkSettings() async {
    final storage = await StorageService.getInstance();
    setState(() {
      _wmShowStatus =
          storage.getSetting<bool>('watermarkShowStatus', defaultValue: true) ??
              true;
      _wmShowTitle =
          storage.getSetting<bool>('watermarkShowTitle', defaultValue: true) ??
              true;
      _wmShowDateTime = storage.getSetting<bool>('watermarkShowDateTime',
              defaultValue: true) ??
          true;
      _wmShowLocation = storage.getSetting<bool>('watermarkShowLocation',
              defaultValue: true) ??
          true;
      _wmShowWorkorder = storage.getSetting<bool>('watermarkShowWorkorder',
              defaultValue: true) ??
          true;
    });
  }

  Future<void> _loadCustomizationSettings() async {
    final storage = await StorageService.getInstance();

    final driveWorkorderRootPath = storage.getSetting<String>(
          'driveWorkorderRootPath',
          defaultValue: 'Jobs',
        ) ??
        'Jobs';
    final driveFolderTemplate = storage.getSetting<String>(
          'driveFolderTemplate',
          defaultValue: 'Jobs/{workorderNumber}/Photos/{processStage}',
        ) ??
        'Jobs/{workorderNumber}/Photos/{processStage}';
    final fileNameTemplate = storage.getSetting<String>(
          'fileNameTemplate',
          defaultValue: '{component}_Photo{photoNumber}_{initials}.jpg',
        ) ??
        '{component}_Photo{photoNumber}_{initials}.jpg';
    final watermarkTitleTemplate = storage.getSetting<String>(
          'watermarkTitleTemplate',
          defaultValue: '{fileName}',
        ) ??
        '{fileName}';

    setState(() {
      _driveWorkorderRootPathController.text = driveWorkorderRootPath;
      _driveFolderTemplateController.text = driveFolderTemplate;
      _fileNameTemplateController.text = fileNameTemplate;
      _watermarkTitleTemplateController.text = watermarkTitleTemplate;

      _watermarkFontSize =
          storage.getSetting<int>('watermarkFontSize', defaultValue: 24) ?? 24;
      _watermarkTextColor = storage.getSetting<int>(
            'watermarkTextColor',
            defaultValue: 0xFFFFFFFF,
          ) ??
          0xFFFFFFFF;
      _watermarkBackgroundOpacity = storage.getSetting<double>(
            'watermarkBackgroundOpacity',
            defaultValue: 1.0,
          ) ??
          1.0;
      _watermarkShowLogo = storage.getSetting<bool>(
            'watermarkShowLogo',
            defaultValue: false,
          ) ??
          false;
      _watermarkLogoPath =
          storage.getSetting<String>('watermarkLogoPath') ?? '';
      _watermarkLogoScale = storage.getSetting<double>(
            'watermarkLogoScale',
            defaultValue: 0.25,
          ) ??
          0.25;
    });
  }

  Future<void> _saveStringSetting(String key, String value) async {
    final storage = await StorageService.getInstance();
    await storage.setSetting(key, value.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved')),
      );
    }
  }

  Future<void> _saveIntSetting(String key, int value) async {
    final storage = await StorageService.getInstance();
    await storage.setSetting(key, value);
  }

  Future<void> _saveDoubleSetting(String key, double value) async {
    final storage = await StorageService.getInstance();
    await storage.setSetting(key, value);
  }

  Future<void> _saveBoolSetting(String key, bool value) async {
    final storage = await StorageService.getInstance();
    await storage.setSetting(key, value);
  }

  Future<void> _pickWatermarkLogo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        return;
      }

      setState(() {
        _watermarkLogoPath = picked.path;
        _watermarkShowLogo = true;
      });
      await _saveStringSetting('watermarkLogoPath', picked.path);
      await _saveBoolSetting('watermarkShowLogo', true);
    } catch (_) {}
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
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Watermark Content',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          _buildWatermarkOptionRow(
                            label: 'Status & Urgency',
                            value: _wmShowStatus,
                            onChanged: (value) => _updateWatermarkSetting(
                              'watermarkShowStatus',
                              value,
                              (v) => _wmShowStatus = v,
                            ),
                          ),
                          _buildWatermarkOptionRow(
                            label: 'Title (Component & Photo #)',
                            value: _wmShowTitle,
                            onChanged: (value) => _updateWatermarkSetting(
                              'watermarkShowTitle',
                              value,
                              (v) => _wmShowTitle = v,
                            ),
                          ),
                          _buildWatermarkOptionRow(
                            label: 'Date & Time',
                            value: _wmShowDateTime,
                            onChanged: (value) => _updateWatermarkSetting(
                              'watermarkShowDateTime',
                              value,
                              (v) => _wmShowDateTime = v,
                            ),
                          ),
                          _buildWatermarkOptionRow(
                            label: 'Location',
                            value: _wmShowLocation,
                            onChanged: (value) => _updateWatermarkSetting(
                              'watermarkShowLocation',
                              value,
                              (v) => _wmShowLocation = v,
                            ),
                          ),
                          _buildWatermarkOptionRow(
                            label: 'Work Order / Component / Stage',
                            value: _wmShowWorkorder,
                            onChanged: (value) => _updateWatermarkSetting(
                              'watermarkShowWorkorder',
                              value,
                              (v) => _wmShowWorkorder = v,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Drive Organization',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _driveWorkorderRootPathController,
                            decoration: const InputDecoration(
                              labelText: 'Workorder Root Path',
                              hintText: 'Jobs',
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) => _saveStringSetting(
                                'driveWorkorderRootPath', value),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _driveFolderTemplateController,
                            decoration: const InputDecoration(
                              labelText: 'Upload Folder Template',
                              hintText:
                                  'Jobs/{workorderNumber}/Photos/{processStage}',
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) => _saveStringSetting(
                                'driveFolderTemplate', value),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Placeholders: {workorderNumber}, {processStage}, {component}, {project}, {componentPart}, {componentStamp}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'File Naming',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _fileNameTemplateController,
                            decoration: const InputDecoration(
                              labelText: 'File Name Template',
                              hintText:
                                  '{component}_Photo{photoNumber}_{initials}.jpg',
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) =>
                                _saveStringSetting('fileNameTemplate', value),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Placeholders: {component}, {photoNumber}, {initials}, {workorderNumber}, {processStage}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _watermarkTitleTemplateController,
                            decoration: const InputDecoration(
                              labelText: 'Watermark Title Template',
                              hintText: '{fileName}',
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) => _saveStringSetting(
                              'watermarkTitleTemplate',
                              value,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Placeholders: {fileName}, {workorderNumber}, {component}, {processStage}, {project}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Watermark Appearance',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Font size: $_watermarkFontSize',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _watermarkFontSize.toDouble(),
                            min: 14,
                            max: 48,
                            divisions: 34,
                            label: _watermarkFontSize.toString(),
                            onChanged: (value) async {
                              final v = value.round();
                              setState(() {
                                _watermarkFontSize = v;
                              });
                              await _saveIntSetting('watermarkFontSize', v);
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Background opacity: ${_watermarkBackgroundOpacity.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _watermarkBackgroundOpacity,
                            min: 0.0,
                            max: 1.0,
                            divisions: 20,
                            label:
                                _watermarkBackgroundOpacity.toStringAsFixed(2),
                            onChanged: (value) async {
                              setState(() {
                                _watermarkBackgroundOpacity = value;
                              });
                              await _saveDoubleSetting(
                                'watermarkBackgroundOpacity',
                                value,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _watermarkTextColor,
                            decoration: const InputDecoration(
                              labelText: 'Text Color',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 0xFFFFFFFF,
                                child: Text('White'),
                              ),
                              DropdownMenuItem(
                                value: 0xFF000000,
                                child: Text('Black'),
                              ),
                              DropdownMenuItem(
                                value: 0xFFFFEB3B,
                                child: Text('Yellow'),
                              ),
                              DropdownMenuItem(
                                value: 0xFFF44336,
                                child: Text('Red'),
                              ),
                              DropdownMenuItem(
                                value: 0xFF2196F3,
                                child: Text('Blue'),
                              ),
                            ],
                            onChanged: (value) async {
                              if (value == null) return;
                              setState(() {
                                _watermarkTextColor = value;
                              });
                              await _saveIntSetting(
                                  'watermarkTextColor', value);
                            },
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Watermark Logo',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          _buildWatermarkOptionRow(
                            label: 'Enable logo watermark',
                            value: _watermarkShowLogo,
                            onChanged: (value) async {
                              setState(() {
                                _watermarkShowLogo = value;
                              });
                              await _saveBoolSetting(
                                  'watermarkShowLogo', value);
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _watermarkLogoPath.isEmpty
                                      ? 'No logo selected'
                                      : _watermarkLogoPath,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          color: Theme.of(context).hintColor),
                                ),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: _pickWatermarkLogo,
                                child: const Text('Select'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    _watermarkLogoPath = '';
                                    _watermarkShowLogo = false;
                                  });
                                  await _saveStringSetting(
                                      'watermarkLogoPath', '');
                                  await _saveBoolSetting(
                                      'watermarkShowLogo', false);
                                },
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Logo scale: ${_watermarkLogoScale.toStringAsFixed(2)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _watermarkLogoScale,
                            min: 0.10,
                            max: 0.50,
                            divisions: 40,
                            label: _watermarkLogoScale.toStringAsFixed(2),
                            onChanged: (value) async {
                              setState(() {
                                _watermarkLogoScale = value;
                              });
                              await _saveDoubleSetting(
                                  'watermarkLogoScale', value);
                            },
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
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildWatermarkOptionRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _updateWatermarkSetting(
    String key,
    bool value,
    void Function(bool) assign,
  ) async {
    setState(() {
      assign(value);
    });
    final storage = await StorageService.getInstance();
    await storage.setSetting(key, value);
  }
}
