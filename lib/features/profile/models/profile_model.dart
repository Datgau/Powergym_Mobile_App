/// ─── Profile models ───────────────────────────────────────────────────────────

class UserProfile {
  final int id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? avatar;
  final String? dateOfBirth;
  final String? bio;
  final String role;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatar,
    this.dateOfBirth,
    this.bio,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id:          json['id'] as int,
        fullName:    json['fullName'] as String? ?? '',
        email:       json['email'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String?,
        avatar:      json['avatar'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
        bio:         json['bio'] as String?,
        role: json['role'] is Map
            ? (json['role'] as Map)['name'] as String? ?? ''
            : json['role'] as String? ?? '',
      );

  String get firstName => fullName.split(' ').last;
}

class UpdateProfileRequest {
  final String? fullName;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? bio;

  const UpdateProfileRequest({
    this.fullName,
    this.phoneNumber,
    this.dateOfBirth,
    this.bio,
  });

  Map<String, dynamic> toJson() => {
        if (fullName != null)    'fullName': fullName,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (bio != null)         'bio': bio,
      };
}
