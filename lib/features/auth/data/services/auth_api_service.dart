import 'package:powergym_mobile_app/core/network/api.dart';
import '../models/auth_models.dart';

/// Auth-specific API calls — uses the shared Api.public Dio instance.
class AuthApiService {
  Future<ApiResponse<LoginResponse>> login(LoginRequest req) async {
    final res = await Api.public.post('/auth/login', data: req.toJson());
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => LoginResponse.fromJson(d as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<void>> register(RegisterRequest req) async {
    final res = await Api.public.post('/auth/register', data: req.toJson());
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, null);
  }

  Future<ApiResponse<void>> verifyOtp(VerifyOtpRequest req) async {
    final res = await Api.public.post('/auth/verify-otp', data: req.toJson());
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, null);
  }

  Future<ApiResponse<void>> resendOtp(String email) async {
    final res = await Api.public.post(
      '/auth/resend-otp',
      data: ResendOtpRequest(email: email).toJson(),
    );
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, null);
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    final res = await Api.public.post(
      '/auth/forgot-password',
      queryParameters: {'email': email},
    );
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, null);
  }
}
