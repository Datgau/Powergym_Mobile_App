// ─── User Profile ─────────────────────────────────────────────────────────────

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
        id: json['id'] as int,
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String?,
        avatar: json['avatar'] as String?,
        dateOfBirth: json['dateOfBirth'] as String?,
        bio: json['bio'] as String?,
        role: json['role'] is Map
            ? (json['role'] as Map)['name'] as String? ?? ''
            : json['role'] as String? ?? '',
      );

  String get firstName => fullName.split(' ').last;
}

// ─── Trainer Booking ──────────────────────────────────────────────────────────

class TrainerBookingItem {
  final int id;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? trainerName;
  final String? trainerAvatar;
  final String? serviceName;

  const TrainerBookingItem({
    required this.id,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.trainerName,
    this.trainerAvatar,
    this.serviceName,
  });

  factory TrainerBookingItem.fromJson(Map<String, dynamic> json) {
    final trainer = json['trainer'] as Map<String, dynamic>?;
    final service = json['serviceRegistration'] as Map<String, dynamic>?;
    final gymService = service?['gymService'] as Map<String, dynamic>?;

    return TrainerBookingItem(
      id: json['id'] as int,
      bookingDate: json['bookingDate'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      status: json['status'] as String? ?? '',
      trainerName: trainer?['fullName'] as String?,
      trainerAvatar: trainer?['avatar'] as String?,
      serviceName: gymService?['name'] as String?,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'CONFIRMED': return 'Đã xác nhận';
      case 'PENDING':   return 'Chờ xác nhận';
      case 'CANCELLED': return 'Đã hủy';
      case 'COMPLETED': return 'Hoàn thành';
      case 'REJECTED':  return 'Đã từ chối';
      default:          return status;
    }
  }

  bool get isUpcoming =>
      status == 'CONFIRMED' || status == 'PENDING';
}

// ─── Membership Package ───────────────────────────────────────────────────────

class MembershipPackageItem {
  final int id;
  final String name;
  final String? description;
  final int duration;
  final double price;
  final List<String> features;
  final bool isActive;

  const MembershipPackageItem({
    required this.id,
    required this.name,
    this.description,
    required this.duration,
    required this.price,
    required this.features,
    required this.isActive,
  });

  factory MembershipPackageItem.fromJson(Map<String, dynamic> json) {
    List<String> featureList = [];
    final raw = json['features'];
    if (raw is List) {
      featureList = raw.map((e) => e.toString()).toList();
    } else if (raw is String && raw.isNotEmpty) {
      featureList = raw.split(',').map((e) => e.trim()).toList();
    }

    return MembershipPackageItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      duration: json['duration'] as int? ?? 30,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      features: featureList,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  String get formattedPrice {
    final parts = price.toInt().toString().split('').reversed.toList();
    final result = <String>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && i % 3 == 0) result.add('.');
      result.add(parts[i]);
    }
    return '${result.reversed.join()}đ';
  }
}
