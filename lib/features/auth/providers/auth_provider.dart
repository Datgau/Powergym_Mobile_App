import 'package:flutter/foundation.dart';
import '../../../services/api.dart';
import '../data/models/auth_models.dart';
import '../data/services/auth_api_service.dart';
import '../../shared/storage/auth_storage.dart';

enum AuthStatus { idle, loading, success, error }

/// Allowed roles for mobile app access
const _allowedRoles = {'USER', 'TRAINER'};

class AuthProvider extends ChangeNotifier {
  final AuthApiService _api = AuthApiService();
  final AuthStorage _storage = AuthStorage();

  AuthStatus _status = AuthStatus.idle;
  String _errorMessage = '';
  LoginResponse? _currentUser;

  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  LoginResponse? get currentUser => _currentUser;
  bool get isLoading => _status == AuthStatus.loading;

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String msg) {
    _status = AuthStatus.error;
    _errorMessage = msg;
    notifyListeners();
  }

  void _setSuccess() {
    _status = AuthStatus.success;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    _status = AuthStatus.idle;
    notifyListeners();
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _setLoading();
    try {
      final res = await _api.login(LoginRequest(email: email, password: password));

      if (!res.success || res.data == null) {
        _setError(res.message.isNotEmpty ? res.message : 'Login failed.');
        return false;
      }

      final user = res.data!;

      // Block ADMIN and STAFF from mobile app
      if (!_allowedRoles.contains(user.role.toUpperCase())) {
        _setError('This app is for members and trainers only.');
        return false;
      }

      await _storage.saveSession(
        accessToken: user.accessToken,
        userId: user.id.toString(),
        role: user.role,
        fullName: user.fullName,
        email: user.email,
        avatar: user.avatar,
      );

      _currentUser = user;
      _setSuccess();
      return true;
    } catch (e) {
      _setError(Api.parseError(e));
      return false;
    }
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final res = await _api.register(
        RegisterRequest(fullName: fullName, email: email, password: password),
      );

      if (!res.success) {
        _setError(res.message.isNotEmpty ? res.message : 'Registration failed.');
        return false;
      }

      _setSuccess();
      return true;
    } catch (e) {
      _setError(Api.parseError(e));
      return false;
    }
  }

  // ─── Verify OTP ───────────────────────────────────────────────────────────

  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading();
    try {
      final res = await _api.verifyOtp(VerifyOtpRequest(email: email, otp: otp));

      if (!res.success) {
        _setError(res.message.isNotEmpty ? res.message : 'Invalid OTP.');
        return false;
      }

      _setSuccess();
      return true;
    } catch (e) {
      _setError(Api.parseError(e));
      return false;
    }
  }

  // ─── Resend OTP ───────────────────────────────────────────────────────────

  Future<bool> resendOtp(String email) async {
    _setLoading();
    try {
      final res = await _api.resendOtp(email);
      if (!res.success) {
        _setError(res.message.isNotEmpty ? res.message : 'Failed to resend OTP.');
        return false;
      }
      _setSuccess();
      return true;
    } catch (e) {
      _setError(Api.parseError(e));
      return false;
    }
  }

  // ─── Forgot password ──────────────────────────────────────────────────────

  Future<bool> forgotPassword(String email) async {
    _setLoading();
    try {
      final res = await _api.forgotPassword(email);
      if (!res.success) {
        _setError(res.message.isNotEmpty ? res.message : 'Failed to send reset email.');
        return false;
      }
      _setSuccess();
      return true;
    } catch (e) {
      _setError(Api.parseError(e));
      return false;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _storage.clearSession();
    _currentUser = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }
}
