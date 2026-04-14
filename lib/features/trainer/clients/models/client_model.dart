/// Maps từ ServiceRegistrationWithTrainerResponse của backend
class ClientModel {
  final int registrationId;
  final int userId;
  final String fullName;
  final String email;
  final String? avatar;
  final String serviceName;
  final String registrationStatus;
  final int totalBookings;
  final bool hasTrainer;

  const ClientModel({
    required this.registrationId,
    required this.userId,
    required this.fullName,
    required this.email,
    this.avatar,
    required this.serviceName,
    required this.registrationStatus,
    required this.totalBookings,
    required this.hasTrainer,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) => ClientModel(
        registrationId: json['id'] as int? ?? 0,
        userId: json['userId'] as int? ?? 0,
        fullName: (json['userName'] as String?) ?? '',
        email: (json['userEmail'] as String?) ?? '',
        avatar: json['userAvatar'] as String?,
        serviceName: (json['serviceName'] as String?) ?? '',
        registrationStatus: (json['status'] as String?) ?? 'ACTIVE',
        totalBookings: json['totalBookings'] as int? ?? 0,
        hasTrainer: json['hasTrainer'] as bool? ?? false,
      );

  bool get isActive => registrationStatus == 'ACTIVE';
}
