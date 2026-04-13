import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../features/shared/storage/auth_storage.dart';
class Api {
  Api._();
  static const String baseUrl = kIsWeb
      ? 'http://localhost:8080/api'
      : 'http://192.168.1.11:8080/api';
  static const Duration _connectTimeout = Duration(seconds: 15);
  static const Duration _receiveTimeout = Duration(seconds: 20);
  static final Dio public = _buildDio(withAuth: false);

  /// Private client — injects Bearer token automatically.
  static final Dio private = _buildDio(withAuth: true);

  // ─── Factory ──────────────────────────────────────────────────────────────

  static Dio _buildDio({required bool withAuth}) {
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

    if (withAuth) {
      dio.interceptors.add(_AuthInterceptor());
    }

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

  // ─── Error parser ─────────────────────────────────────────────────────────

  /// Extracts a human-readable message from any Dio or generic error.
  static String parseError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'] as String;
      }
      switch (e.response?.statusCode) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Invalid credentials. Please try again.';
        case 403:
          return 'Access denied.';
        case 404:
          return 'Resource not found.';
        case 500:
          return 'Server error. Please try again later.';
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
}
