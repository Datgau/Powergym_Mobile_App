// ─── Request models ───────────────────────────────────────────────────────────

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String fullName;
  final String email;
  final String password;

  const RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
      };
}

class VerifyOtpRequest {
  final String email;
  final String otp;

  const VerifyOtpRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

class ResendOtpRequest {
  final String email;

  const ResendOtpRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

// ─── Response models ──────────────────────────────────────────────────────────

class LoginResponse {
  final int id;
  final String role;
  final String email;
  final String fullName;
  final String? avatar;
  final String accessToken;

  const LoginResponse({
    required this.id,
    required this.role,
    required this.email,
    required this.fullName,
    this.avatar,
    required this.accessToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // Backend trả: { ..., "token": { "accessToken": "...", "expiresIn": 1800 } }
    final token = json['token'] as Map<String, dynamic>? ?? {};
    return LoginResponse(
      id: json['id'] as int,
      role: json['role'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      avatar: json['avatar'] as String?,
      accessToken: token['accessToken'] as String? ?? '',
    );
  }
}

// ─── Wrapper ──────────────────────────────────────────────────────────────────

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int status;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.status,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : null,
      status: json['status'] as int? ?? 0,
    );
  }
}
