import '../../../core/network/api.dart';
import '../models/profile_model.dart';

/// ─── Profile API service ──────────────────────────────────────────────────────
class ProfileService {
  // GET /user/profile
  Future<UserProfile> getProfile() async {
    final res = await Api.private.get('/user/profile');
    return UserProfile.fromJson(
      (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  // PUT /user/profile
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    final res = await Api.private.put('/user/profile', data: request.toJson());
    return UserProfile.fromJson(
      (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  // PUT /user/password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await Api.private.put('/user/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
  }
}
