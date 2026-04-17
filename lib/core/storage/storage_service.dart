import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  
  StorageService._internal();

  SharedPreferences? _prefs;

  // Initialize storage
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Ensure preferences are initialized
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ========== Authentication Keys ==========
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserData = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // ========== App Settings Keys ==========
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyLanguage = 'language';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyFirstLaunch = 'first_launch';

  // ========== Authentication Methods ==========
  
  // Save access token
  Future<bool> saveAccessToken(String token) async {
    final prefs = await _preferences;
    return await prefs.setString(_keyAccessToken, token);
  }

  // Get access token
  Future<String?> getAccessToken() async {
    final prefs = await _preferences;
    return prefs.getString(_keyAccessToken);
  }

  // Save refresh token
  Future<bool> saveRefreshToken(String token) async {
    final prefs = await _preferences;
    return await prefs.setString(_keyRefreshToken, token);
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await _preferences;
    return prefs.getString(_keyRefreshToken);
  }

  // Save user ID
  Future<bool> saveUserId(String userId) async {
    final prefs = await _preferences;
    return await prefs.setString(_keyUserId, userId);
  }

  // Get user ID
  Future<String?> getUserId() async {
    final prefs = await _preferences;
    return prefs.getString(_keyUserId);
  }

  // Save user data
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await _preferences;
    final jsonString = json.encode(userData);
    return await prefs.setString(_keyUserData, jsonString);
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(_keyUserData);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // Set login status
  Future<bool> setLoggedIn(bool isLoggedIn) async {
    final prefs = await _preferences;
    return await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Save complete auth session
  Future<bool> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    await saveUserId(userId);
    await saveUserData(userData);
    return await setLoggedIn(true);
  }

  // Clear auth session (logout)
  Future<bool> clearAuthSession() async {
    final prefs = await _preferences;
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserData);
    return await setLoggedIn(false);
  }

  // ========== App Settings Methods ==========

  // Save theme mode (light/dark/system)
  Future<bool> saveThemeMode(String mode) async {
    final prefs = await _preferences;
    return await prefs.setString(_keyThemeMode, mode);
  }

  // Get theme mode
  Future<String> getThemeMode() async {
    final prefs = await _preferences;
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  // Save language
  Future<bool> saveLanguage(String languageCode) async {
    final prefs = await _preferences;
    return await prefs.setString(_keyLanguage, languageCode);
  }

  // Get language
  Future<String> getLanguage() async {
    final prefs = await _preferences;
    return prefs.getString(_keyLanguage) ?? 'vi';
  }

  // Save notifications enabled
  Future<bool> saveNotificationsEnabled(bool enabled) async {
    final prefs = await _preferences;
    return await prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  // Get notifications enabled
  Future<bool> getNotificationsEnabled() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyNotificationsEnabled) ?? true;
  }

  // Check if first launch
  Future<bool> isFirstLaunch() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  // Set first launch completed
  Future<bool> setFirstLaunchCompleted() async {
    final prefs = await _preferences;
    return await prefs.setBool(_keyFirstLaunch, false);
  }

  // ========== Generic Methods ==========

  // Save string
  Future<bool> saveString(String key, String value) async {
    final prefs = await _preferences;
    return await prefs.setString(key, value);
  }

  // Get string
  Future<String?> getString(String key) async {
    final prefs = await _preferences;
    return prefs.getString(key);
  }

  // Save int
  Future<bool> saveInt(String key, int value) async {
    final prefs = await _preferences;
    return await prefs.setInt(key, value);
  }

  // Get int
  Future<int?> getInt(String key) async {
    final prefs = await _preferences;
    return prefs.getInt(key);
  }

  // Save bool
  Future<bool> saveBool(String key, bool value) async {
    final prefs = await _preferences;
    return await prefs.setBool(key, value);
  }

  // Get bool
  Future<bool?> getBool(String key) async {
    final prefs = await _preferences;
    return prefs.getBool(key);
  }

  // Save double
  Future<bool> saveDouble(String key, double value) async {
    final prefs = await _preferences;
    return await prefs.setDouble(key, value);
  }

  // Get double
  Future<double?> getDouble(String key) async {
    final prefs = await _preferences;
    return prefs.getDouble(key);
  }

  // Save list of strings
  Future<bool> saveStringList(String key, List<String> value) async {
    final prefs = await _preferences;
    return await prefs.setStringList(key, value);
  }

  // Get list of strings
  Future<List<String>?> getStringList(String key) async {
    final prefs = await _preferences;
    return prefs.getStringList(key);
  }

  // Save JSON object
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    final prefs = await _preferences;
    final jsonString = json.encode(value);
    return await prefs.setString(key, jsonString);
  }

  // Get JSON object
  Future<Map<String, dynamic>?> getJson(String key) async {
    final prefs = await _preferences;
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      return json.decode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // Remove specific key
  Future<bool> remove(String key) async {
    final prefs = await _preferences;
    return await prefs.remove(key);
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    final prefs = await _preferences;
    return prefs.containsKey(key);
  }

  // Clear all data
  Future<bool> clearAll() async {
    final prefs = await _preferences;
    return await prefs.clear();
  }

  // Get all keys
  Future<Set<String>> getAllKeys() async {
    final prefs = await _preferences;
    return prefs.getKeys();
  }
}
