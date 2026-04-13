import 'package:shared_preferences/shared_preferences.dart';

/// Isolated storage for auth feature — does NOT touch existing StorageService.
class AuthStorage {
  static const _keyToken = 'auth_feature_token';
  static const _keyUserId = 'auth_feature_user_id';
  static const _keyRole = 'auth_feature_role';
  static const _keyFullName = 'auth_feature_full_name';
  static const _keyEmail = 'auth_feature_email';
  static const _keyAvatar = 'auth_feature_avatar';

  Future<void> saveSession({
    required String accessToken,
    required String userId,
    required String role,
    required String fullName,
    required String email,
    String? avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, accessToken);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyFullName, fullName);
    await prefs.setString(_keyEmail, email);
    if (avatar != null) await prefs.setString(_keyAvatar, avatar);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyFullName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyAvatar);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
