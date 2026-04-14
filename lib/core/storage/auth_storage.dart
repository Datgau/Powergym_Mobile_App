import 'package:shared_preferences/shared_preferences.dart';

/// ─── Auth session storage ─────────────────────────────────────────────────────
///
/// Stores the access token and basic user info after login.
/// Uses prefixed keys to avoid conflicts with other storage.
class AuthStorage {
  static const _keyToken    = 'auth_token';
  static const _keyUserId   = 'auth_user_id';
  static const _keyRole     = 'auth_role';
  static const _keyFullName = 'auth_full_name';
  static const _keyEmail    = 'auth_email';
  static const _keyAvatar   = 'auth_avatar';

  Future<void> saveSession({
    required String accessToken,
    required String userId,
    required String role,
    required String fullName,
    required String email,
    String? avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken,    accessToken);
    await prefs.setString(_keyUserId,   userId);
    await prefs.setString(_keyRole,     role);
    await prefs.setString(_keyFullName, fullName);
    await prefs.setString(_keyEmail,    email);
    if (avatar != null) await prefs.setString(_keyAvatar, avatar);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in [_keyToken, _keyUserId, _keyRole, _keyFullName, _keyEmail, _keyAvatar]) {
      await prefs.remove(key);
    }
  }

  Future<String?> getToken()    async => (await SharedPreferences.getInstance()).getString(_keyToken);
  Future<String?> getUserId()   async => (await SharedPreferences.getInstance()).getString(_keyUserId);
  Future<String?> getRole()     async => (await SharedPreferences.getInstance()).getString(_keyRole);
  Future<String?> getFullName() async => (await SharedPreferences.getInstance()).getString(_keyFullName);
  Future<String?> getEmail()    async => (await SharedPreferences.getInstance()).getString(_keyEmail);
  Future<String?> getAvatar()   async => (await SharedPreferences.getInstance()).getString(_keyAvatar);

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
