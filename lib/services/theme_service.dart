import 'package:flutter/material.dart';
import 'storage_service.dart';

class ThemeService {
  static ThemeService? _instance;
  static ThemeService get instance => _instance ??= ThemeService._();

  ThemeService._();

  late StorageService _storageService;
  final ValueNotifier<ThemeMode> _themeModeNotifier =
      ValueNotifier(ThemeMode.light);

  ValueNotifier<ThemeMode> get themeModeNotifier => _themeModeNotifier;
  ThemeMode get currentTheme => _themeModeNotifier.value;

  Future<void> initialize() async {
    _storageService = await StorageService.getInstance();
    final isDarkMode =
        _storageService.getSetting('darkMode', defaultValue: false) ?? false;
    _themeModeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final newTheme = _themeModeNotifier.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    _themeModeNotifier.value = newTheme;
    await _storageService.setSetting('darkMode', newTheme == ThemeMode.dark);
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    _themeModeNotifier.value = themeMode;
    await _storageService.setSetting('darkMode', themeMode == ThemeMode.dark);
  }

  bool isDarkMode() => _themeModeNotifier.value == ThemeMode.dark;
}
