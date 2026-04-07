import 'package:dio/dio.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();

  // Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'rememberMe': rememberMe,
        },
      );

      final data = response.data;
      
      // Save auth session
      await _storage.saveAuthSession(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        userId: data['user']['id'].toString(),
        userData: data['user'],
      );

      return data;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Register new user
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
        },
      );

      final data = response.data;
      
      // Save auth session
      await _storage.saveAuthSession(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        userId: data['user']['id'].toString(),
        userData: data['user'],
      );

      return data;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call logout API (optional - to invalidate token on server)
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      // Clear local storage
      await _storage.clearAuthSession();
    }
  }

  // Refresh access token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      
      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }

      final response = await _apiClient.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;
      
      // Save new tokens
      await _storage.saveAccessToken(data['accessToken']);
      await _storage.saveRefreshToken(data['refreshToken']);

      return data;
    } catch (e) {
      // If refresh fails, logout user
      await logout();
      throw Exception('Token refresh failed: ${e.toString()}');
    }
  }

  // Forgot password - send reset email
  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } catch (e) {
      throw Exception('Failed to send reset email: ${e.toString()}');
    }
  }

  // Reset password with token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw Exception('Failed to reset password: ${e.toString()}');
    }
  }

  // Change password (when logged in)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.put(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  // Verify email with token
  Future<void> verifyEmail(String token) async {
    try {
      await _apiClient.post(
        '/auth/verify-email',
        data: {'token': token},
      );
    } catch (e) {
      throw Exception('Email verification failed: ${e.toString()}');
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _apiClient.post(
        '/auth/resend-verification',
        data: {'email': email},
      );
    } catch (e) {
      throw Exception('Failed to resend verification email: ${e.toString()}');
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final isLoggedIn = await _storage.isLoggedIn();
    final accessToken = await _storage.getAccessToken();
    return isLoggedIn && accessToken != null;
  }

  // Get current user data from storage
  Future<Map<String, dynamic>?> getCurrentUser() async {
    return await _storage.getUserData();
  }

  // Get current user ID
  Future<String?> getCurrentUserId() async {
    return await _storage.getUserId();
  }

  // Update user data in storage
  Future<void> updateUserData(Map<String, dynamic> userData) async {
    await _storage.saveUserData(userData);
  }

  // Social login - Google
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await _apiClient.post(
        '/auth/google',
        data: {'idToken': idToken},
      );

      final data = response.data;
      
      // Save auth session
      await _storage.saveAuthSession(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        userId: data['user']['id'].toString(),
        userData: data['user'],
      );

      return data;
    } catch (e) {
      throw Exception('Google login failed: ${e.toString()}');
    }
  }

  // Social login - Facebook
  Future<Map<String, dynamic>> loginWithFacebook(String accessToken) async {
    try {
      final response = await _apiClient.post(
        '/auth/facebook',
        data: {'accessToken': accessToken},
      );

      final data = response.data;
      
      // Save auth session
      await _storage.saveAuthSession(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
        userId: data['user']['id'].toString(),
        userData: data['user'],
      );

      return data;
    } catch (e) {
      throw Exception('Facebook login failed: ${e.toString()}');
    }
  }

  // Check token validity
  Future<bool> validateToken() async {
    try {
      await _apiClient.get('/auth/validate');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Delete account
  Future<void> deleteAccount(String password) async {
    try {
      await _apiClient.delete(
        '/auth/account',
        data: {'password': password},
      );
      
      // Clear local storage
      await _storage.clearAuthSession();
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }
}
