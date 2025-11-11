import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buddyapp/utils/app_constants.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._internal();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._internal();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Generic Methods
  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  String? getString(String key, {String? defaultValue}) {
    return _preferences?.getString(key) ?? defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  int? getInt(String key, {int? defaultValue}) {
    return _preferences?.getInt(key) ?? defaultValue;
  }

  Future<void> setDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  double? getDouble(String key, {double? defaultValue}) {
    return _preferences?.getDouble(key) ?? defaultValue;
  }

  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  bool? getBool(String key, {bool? defaultValue}) {
    return _preferences?.getBool(key) ?? defaultValue;
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _preferences?.setStringList(key, value);
  }

  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return _preferences?.getStringList(key) ?? defaultValue;
  }

  Future<void> setObject<T>(String key, T value) async {
    final jsonString = jsonEncode(value);
    await setString(key, jsonString);
  }

  T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final jsonString = getString(key);
    if (jsonString == null) return null;

    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    await _preferences?.remove(key);
  }

  Future<void> clear() async {
    await _preferences?.clear();
  }

  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }

  Future<void> reload() async {
    await _preferences?.reload();
  }

  // App Specific Methods
  Future<void> setAuthToken(String token) async {
    await setString(AppConstants.tokenKey, token);
  }

  String? getAuthToken() {
    return getString(AppConstants.tokenKey);
  }

  Future<void> removeAuthToken() async {
    await remove(AppConstants.tokenKey);
  }

  bool hasAuthToken() {
    return containsKey(AppConstants.tokenKey) &&
        (getAuthToken()?.isNotEmpty ?? false);
  }

  Future<void> setUserData(Map<String, dynamic> userData) async {
    await setObject(AppConstants.userKey, userData);
  }

  Map<String, dynamic>? getUserData() {
    return getObject(AppConstants.userKey, (json) => json);
  }

  Future<void> removeUserData() async {
    await remove(AppConstants.userKey);
  }

  bool hasUserData() {
    return containsKey(AppConstants.userKey);
  }

  Future<void> setSelectedJob(Map<String, dynamic> jobData) async {
    await setObject(AppConstants.selectedJobKey, jobData);
  }

  Map<String, dynamic>? getSelectedJob() {
    return getObject(AppConstants.selectedJobKey, (json) => json);
  }

  Future<void> removeSelectedJob() async {
    await remove(AppConstants.selectedJobKey);
  }

  bool hasSelectedJob() {
    return containsKey(AppConstants.selectedJobKey);
  }

  Future<void> setAppSettings(Map<String, dynamic> settings) async {
    await setObject(AppConstants.settingsKey, settings);
  }

  Map<String, dynamic>? getAppSettings() {
    return getObject(AppConstants.settingsKey, (json) => json);
  }

  Future<void> setCameraSettings(Map<String, dynamic> settings) async {
    await setObject(AppConstants.cameraSettingsKey, settings);
  }

  Map<String, dynamic>? getCameraSettings() {
    return getObject(AppConstants.cameraSettingsKey, (json) => json);
  }

  // Settings Management
  Future<void> setSetting(String key, dynamic value) async {
    final settings = getAppSettings() ?? {};
    settings[key] = value;
    await setAppSettings(settings);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    final settings = getAppSettings() ?? {};
    return settings[key] as T? ?? defaultValue;
  }

  Future<void> removeSetting(String key) async {
    final settings = getAppSettings() ?? {};
    settings.remove(key);
    await setAppSettings(settings);
  }

  // Camera Settings Management
  Future<void> setCameraSetting(String key, dynamic value) async {
    final settings = getCameraSettings() ?? {};
    settings[key] = value;
    await setCameraSettings(settings);
  }

  T? getCameraSetting<T>(String key, {T? defaultValue}) {
    final settings = getCameraSettings() ?? {};
    return settings[key] as T? ?? defaultValue;
  }

  Future<void> removeCameraSetting(String key) async {
    final settings = getCameraSettings() ?? {};
    settings.remove(key);
    await setCameraSettings(settings);
  }

  // Cache Management
  Future<void> setCachedData(String key, dynamic data,
      {Duration? expiration}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': expiration?.inMilliseconds,
    };
    await setObject('cache_$key', cacheData);
  }

  T? getCachedData<T>(String key) {
    final cacheData = getObject('cache_$key', (json) => json);
    if (cacheData == null) return null;

    final timestamp = cacheData['timestamp'] as int?;
    final expiration = cacheData['expiration'] as int?;

    if (timestamp == null) return null;

    if (expiration != null) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - timestamp > expiration) {
        remove('cache_$key');
        return null;
      }
    }

    return cacheData['data'] as T?;
  }

  Future<void> clearCache() async {
    final keys = _preferences?.getKeys() ?? {};
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        await remove(key);
      }
    }
  }

  // User Preferences
  Future<void> setUserPreference(String key, dynamic value) async {
    await setObject('pref_$key', value);
  }

  T? getUserPreference<T>(String key, {T? defaultValue}) {
    return getObject('pref_$key', (json) => json) as T? ?? defaultValue;
  }

  Future<void> removeUserPreference(String key) async {
    await remove('pref_$key');
  }

  // Session Management
  Future<void> setSessionData(Map<String, dynamic> sessionData) async {
    await setObject('session', sessionData);
  }

  Map<String, dynamic>? getSessionData() {
    return getObject('session', (json) => json);
  }

  Future<void> clearSessionData() async {
    await remove('session');
  }

  // App State
  Future<void> setAppState(String state) async {
    await setString('app_state', state);
  }

  String? getAppState() {
    return getString('app_state');
  }

  // First Launch
  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await setBool('first_launch', isFirstLaunch);
  }

  bool isFirstLaunch() {
    return getBool('first_launch', defaultValue: true) ?? true;
  }

  // App Version
  Future<void> setAppVersion(String version) async {
    await setString('app_version', version);
  }

  String? getAppVersion() {
    return getString('app_version');
  }

  // Last Sync Time
  Future<void> setLastSyncTime(DateTime syncTime) async {
    await setInt('last_sync', syncTime.millisecondsSinceEpoch);
  }

  DateTime? getLastSyncTime() {
    final timestamp = getInt('last_sync');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // Debug Methods
  Future<void> printAllData() async {
    final keys = _preferences?.getKeys() ?? {};
    print('=== Storage Data ===');
    for (final key in keys) {
      final value = _preferences?.get(key);
      print('$key: $value');
    }
    print('===================');
  }

  Map<String, dynamic> getAllData() {
    final keys = _preferences?.getKeys() ?? {};
    final data = <String, dynamic>{};
    for (final key in keys) {
      data[key] = _preferences?.get(key);
    }
    return data;
  }
}
