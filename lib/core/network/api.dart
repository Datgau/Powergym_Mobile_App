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

  // ─── In-memory token cache (avoids SharedPreferences race condition) ──────
  static String? _cachedToken;
  static String? _cachedRefreshToken;

  static void cacheTokens({required String accessToken, String? refreshToken}) {
    _cachedToken = accessToken;
    if (refreshToken != null) _cachedRefreshToken = refreshToken;
  }

  static void clearCachedTokens() {
    _cachedToken = null;
    _cachedRefreshToken = null;
  }

  static String? get cachedToken => _cachedToken;
  static String? get cachedRefreshToken => _cachedRefreshToken;

  // ─── Dio instances ────────────────────────────────────────────────────────

  /// No auth header — for login, register, public endpoints.
  static final Dio public = _build(withAuth: false);

  /// Injects Bearer token automatically; auto-refreshes on 401.
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

    if (withAuth) dio.interceptors.add(_AuthInterceptor(dio));

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

// ─── Auth interceptor with auto-refresh ──────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final AuthStorage _storage = AuthStorage();
  final Dio _dio;

  // Static flag to prevent multiple simultaneous refresh attempts
  static bool _isRefreshing = false;
  static final List<Function> _pendingRequests = [];

  _AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Use in-memory cache first to avoid SharedPreferences race condition
    final token = Api.cachedToken ?? await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Already refreshing — just pass the error through, don't logout
    if (_isRefreshing) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final newToken = Api.cachedToken ?? await _storage.getToken();
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        final retryResponse = await _dio.fetch(opts);
        handler.resolve(retryResponse);
        return;
      }

      // Refresh failed — only logout if no token in memory
      // (prevents logout on transient 401 right after login)
      final memToken = Api.cachedToken;
      if (memToken != null && memToken.isNotEmpty) {
        // Token exists in memory — retry once, don't logout
        try {
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $memToken';
          final retryResponse = await _dio.fetch(opts);
          handler.resolve(retryResponse);
          return;
        } catch (_) {
          // Retry failed too — pass error through without logout
          handler.next(err);
          return;
        }
      }

      // No token at all — session truly expired, logout
      await _storage.clearSession();
      Api.clearCachedTokens();
      AppNavigator.goToLogin();
      handler.next(err);
    } catch (_) {
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Gọi /auth/refresh-token-mobile, lưu token mới.
  /// Trả về true nếu thành công.
  Future<bool> _tryRefresh() async {
    final refreshToken = Api.cachedRefreshToken ?? await _storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    try {
      // Dùng Dio riêng (không có interceptor) để tránh vòng lặp
      final plainDio = Dio(
        BaseOptions(
          baseUrl: Api.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final res = await plainDio.post(
        '/auth/refresh-token-mobile',
        data: {'refreshToken': refreshToken},
      );

      final body = res.data as Map<String, dynamic>;
      if (body['success'] == true && body['data'] != null) {
        final data = body['data'] as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          await _storage.updateAccessToken(newAccessToken);
          Api.cacheTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _storage.updateRefreshToken(newRefreshToken);
          }
          debugPrint('[Auth] Token refreshed successfully');
          return true;
        }
      }
    } catch (e) {
      debugPrint('[Auth] Refresh failed: $e');
    }
    return false;
  }
}
