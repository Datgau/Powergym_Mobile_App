import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/auth_storage.dart';
import 'app_navigator.dart';

class Api {
  Api._();

  static const String baseUrl = kIsWeb
      ? 'http://localhost:8080/api'
      : 'http://10.0.2.2:8080/api';

  static const Duration _connectTimeout = Duration(seconds: 15);
  static const Duration _receiveTimeout = Duration(seconds: 20);

  // ─── Dio instances ────────────────────────────────────────────────────────

  /// No auth header — for login, register, public endpoints.
  static final Dio public = _build(withAuth: false);

  /// Injects Bearer token automatically from AuthStorage.
  static final Dio private = _build(withAuth: true);

  // ─── Factory ──────────────────────────────────────────────────────────────

  static Dio _build({required bool withAuth}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (withAuth) dio.interceptors.add(_AuthInterceptor());

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (o) => debugPrint('[API] $o'),
      ));
    }

    return dio;
  }

  // ─── Error helper ─────────────────────────────────────────────────────────

  static String parseError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'] as String;
      }
      switch (e.response?.statusCode) {
        case 400: return 'Invalid request. Please check your input.';
        case 401: return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
        case 403: return 'Access denied.';
        case 404: return 'Resource not found.';
        case 500: return 'Server error. Please try again later.';
        default:
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            return 'Connection timed out. Check your internet.';
          }
          return 'Network error. Please try again.';
      }
    }
    return 'An unexpected error occurred.';
  }
}

// ─── Auth interceptor ─────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final AuthStorage _storage = AuthStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token hết hạn hoặc không hợp lệ → clear session và về login
      await _storage.clearSession();
      AppNavigator.goToLogin();
    }
    handler.next(err);
  }
}
