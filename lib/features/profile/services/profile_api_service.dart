import 'dart:io';
import 'package:dio/dio.dart';
import 'package:powergym_mobile_app/core/network/api.dart';

class ProfileApiService {

  // GET /api/user/profile
  Future<Map<String, dynamic>> getProfile() async {
    final res = await Api.private.get('/user/profile');
    return (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  // PUT /api/user/profile (JSON — no avatar)
  Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? dateOfBirth,
    String? bio,
  }) async {
    final res = await Api.private.put('/user/profile', data: {
      if (fullName != null) 'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
      if (bio != null) 'bio': bio,
    });
    return (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  // PUT /api/user/profile/avatar (multipart — avatar only)
  Future<Map<String, dynamic>> updateAvatar(File imageFile) async {
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        imageFile.path,
        filename: 'avatar.jpg',
      ),
    });
    final res = await Api.private.put(
      '/user/profile/avatar',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  // PUT /api/user/password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await Api.private.put('/user/password', data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
  }

  // ── Email change (3-step) ─────────────────────────────────────────

  // Step 1: POST /api/user/email/request-change
  Future<void> requestEmailChange(String newEmail) async {
    await Api.private.post('/user/email/request-change', data: {'newEmail': newEmail});
  }

  // Step 2: POST /api/user/email/verify-current
  Future<void> verifyCurrentEmailOtp(String otp) async {
    await Api.private.post('/user/email/verify-current', data: {'otp': otp});
  }

  // Step 3: POST /api/user/email/verify-new
  Future<Map<String, dynamic>> verifyNewEmailOtp({
    required String newEmail,
    required String otp,
  }) async {
    final res = await Api.private.post('/user/email/verify-new', data: {
      'newEmail': newEmail,
      'otp': otp,
    });
    return (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  // ── Other profile data ────────────────────────────────────────────

  Future<Map<String, dynamic>?> getRewards() async {
    try {
      final res = await Api.private.get('/rewards/me');
      return (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMemberships() async {
    try {
      final res = await Api.private.get('/user/memberships');
      final raw = (res.data as Map<String, dynamic>)['data'];
      if (raw == null) return [];
      return (raw as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentOrders() async {
    try {
      final res = await Api.private.get('/product-orders',
          queryParameters: {'page': 0, 'size': 5});
      final raw = (res.data as Map<String, dynamic>)['data'];
      if (raw == null) return [];
      final content = raw['content'] as List? ?? (raw is List ? raw : []);
      return content.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
