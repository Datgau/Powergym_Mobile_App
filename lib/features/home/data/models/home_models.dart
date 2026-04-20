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
      case 'CONFIRMED': return 'Confirmed';
      case 'PENDING':   return 'Pending';
      case 'CANCELLED': return 'Cancelled';
      case 'COMPLETED': return 'Completed';
      case 'REJECTED':  return 'Rejected';
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

// ─── Service Registration ─────────────────────────────────────────────────────

class ServiceRegistrationItem {
  final int id;
  final String status;
  final String? serviceName;
  final String? startDate;
  final String? endDate;
  final String? registrationDate;
  final String? trainerName;
  final String? trainerAvatar;
  final double? price;
  final int? duration;
  final String? description;
  final String? bookingStatus;
  final List<String> serviceImages;
  final int? memberCount;

  const ServiceRegistrationItem({
    required this.id,
    required this.status,
    this.serviceName,
    this.startDate,
    this.endDate,
    this.registrationDate,
    this.trainerName,
    this.trainerAvatar,
    this.price,
    this.duration,
    this.description,
    this.bookingStatus,
    this.serviceImages = const [],
    this.memberCount,
  });

  factory ServiceRegistrationItem.fromJson(Map<String, dynamic> json) {
    final gymService = json['gymService'] as Map<String, dynamic>?
        ?? json['service'] as Map<String, dynamic>?;
    final trainer = json['trainer'] as Map<String, dynamic>?;

    String? latestBookingStatus;
    final bookings = json['upcomingBookings'] as List?;
    if (bookings != null && bookings.isNotEmpty) {
      latestBookingStatus =
          (bookings.first as Map<String, dynamic>)['status'] as String?;
    }

    final trainerNameFromField = json['trainerName'] as String?;

    // Parse service images
    List<String> images = [];
    if (gymService != null) {
      final rawImages = gymService['images'];
      if (rawImages is List) {
        images = rawImages.cast<String>();
      }
    }

    return ServiceRegistrationItem(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? '',
      serviceName: gymService?['name'] as String?,
      startDate: json['startDate'] as String?
          ?? json['registrationDate'] as String?,
      endDate: json['endDate'] as String?
          ?? json['expirationDate'] as String?,
      registrationDate: json['registrationDate'] as String?,
      trainerName: trainerNameFromField ?? trainer?['fullName'] as String?,
      trainerAvatar: trainer?['avatar'] as String?,
      price: (gymService?['price'] as num?)?.toDouble(),
      duration: gymService?['duration'] as int?,
      description: gymService?['description'] as String?,
      bookingStatus: latestBookingStatus,
      serviceImages: images,
      memberCount: gymService?['registrationCount'] != null
          ? (gymService!['registrationCount'] as num).toInt()
          : null,
    );
  }

  // Active = service is ACTIVE and booking is NOT rejected
  bool get isActive {
    if (status != 'ACTIVE') return false;
    if (bookingStatus == 'REJECTED' || bookingStatus == 'CANCELLED') {
      return false;
    }
    return true;
  }

  String get statusLabel {
    switch (status) {
      case 'ACTIVE':
        if (bookingStatus == 'REJECTED') return 'Trainer rejected';
        if (bookingStatus == 'CANCELLED') return 'Booking cancelled';
        return 'Active';

      case 'CONFIRMED':
        return 'Confirmed';

      case 'PENDING':
        return 'Pending confirmation';

      case 'EXPIRED':
        return 'Expired';

      case 'CANCELLED':
        return 'Cancelled';

      case 'COMPLETED':
        return 'Completed';

      default:
        return status;
    }
  }

  String get formattedPrice {
    if (price == null) return '';
    final parts = price!.toInt().toString().split('').reversed.toList();
    final result = <String>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && i % 3 == 0) result.add('.');
      result.add(parts[i]);
    }
    return '${result.reversed.join()}d';
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

// ─── Active Membership Item ───────────────────────────────────────────────────

class ActiveMembershipItem {
  final int id;
  final String status;
  final String startDate;
  final String endDate;
  final double paidAmount;
  final String packageName;
  final String? packageDescription;
  final int duration;
  final double packagePrice;
  final List<String> features;
  final String? color;

  const ActiveMembershipItem({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.paidAmount,
    required this.packageName,
    this.packageDescription,
    required this.duration,
    required this.packagePrice,
    required this.features,
    this.color,
  });

  factory ActiveMembershipItem.fromJson(Map<String, dynamic> json) {
    final pkg = json['membershipPackage'] as Map<String, dynamic>;
    
    List<String> featureList = [];
    final raw = pkg['features'];
    if (raw is List) {
      featureList = raw.map((e) => e.toString()).toList();
    } else if (raw is String && raw.isNotEmpty) {
      featureList = raw.split(',').map((e) => e.trim()).toList();
    }

    return ActiveMembershipItem(
      id: json['id'] as int,
      status: json['status'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      packageName: pkg['name'] as String? ?? '',
      packageDescription: pkg['description'] as String?,
      duration: pkg['duration'] as int? ?? 30,
      packagePrice: (pkg['price'] as num?)?.toDouble() ?? 0,
      features: featureList,
      color: pkg['color'] as String?,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'ACTIVE': return 'Active';
      case 'EXPIRED': return 'Expired';
      case 'CANCELLED': return 'Cancelled';
      default: return status;
    }
  }

  String get formattedPrice {
    final parts = paidAmount.toInt().toString().split('').reversed.toList();
    final result = <String>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && i % 3 == 0) result.add('.');
      result.add(parts[i]);
    }
    return '${result.reversed.join()}đ';
  }

  int get remainingDays {
    try {
      if (endDate.isEmpty) return 0;
      final end = DateTime.parse(endDate);
      final now = DateTime.now();
      final days = end.difference(now).inDays;
      return days > 0 ? days : 0;
    } catch (e) {
      return 0;
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}