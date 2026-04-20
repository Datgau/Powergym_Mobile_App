class TrainerDashboard {
  final TrainerStats stats;
  final List<TrainerBookingItem> pendingBookings;
  final List<TrainerBookingItem> upcomingBookings;

  const TrainerDashboard({
    required this.stats,
    required this.pendingBookings,
    required this.upcomingBookings,
  });
}

class TrainerSalaryData {
  final int trainerId;
  final String trainerName;
  final double totalSalary;
  final List<ServiceSalaryDetail> serviceBreakdown;
  final String calculatedAt;

  const TrainerSalaryData({
    required this.trainerId,
    required this.trainerName,
    required this.totalSalary,
    required this.serviceBreakdown,
    required this.calculatedAt,
  });

  factory TrainerSalaryData.fromJson(Map<String, dynamic> json) {
    final breakdownList = json['serviceBreakdown'] as List? ?? [];
    return TrainerSalaryData(
      trainerId: json['trainerId'] as int? ?? 0,
      trainerName: json['trainerName'] as String? ?? '',
      totalSalary: (json['totalSalary'] as num?)?.toDouble() ?? 0.0,
      serviceBreakdown: breakdownList
          .map((e) => ServiceSalaryDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      calculatedAt: json['calculatedAt'] as String? ?? '',
    );
  }

  factory TrainerSalaryData.empty() => const TrainerSalaryData(
        trainerId: 0,
        trainerName: '',
        totalSalary: 0.0,
        serviceBreakdown: [],
        calculatedAt: '',
      );
  
  // Helper to get total clients from service breakdown
  int get totalClients {
    return serviceBreakdown.fold<int>(0, (sum, service) => sum + service.studentCount);
  }
}

class ServiceSalaryDetail {
  final int serviceId;
  final String serviceName;
  final int studentCount;
  final double servicePrice;
  final double trainerPercentage;
  final double salaryAmount;

  const ServiceSalaryDetail({
    required this.serviceId,
    required this.serviceName,
    required this.studentCount,
    required this.servicePrice,
    required this.trainerPercentage,
    required this.salaryAmount,
  });

  factory ServiceSalaryDetail.fromJson(Map<String, dynamic> json) {
    return ServiceSalaryDetail(
      serviceId: json['serviceId'] as int? ?? 0,
      serviceName: json['serviceName'] as String? ?? '',
      studentCount: json['studentCount'] as int? ?? 0,
      servicePrice: (json['servicePrice'] as num?)?.toDouble() ?? 0.0,
      trainerPercentage: (json['trainerPercentage'] as num?)?.toDouble() ?? 0.0,
      salaryAmount: (json['salaryAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TrainerStats {
  final int totalClients;
  final int pendingBookings;
  final int upcomingBookings;
  final int completedBookings;
  final double totalEarnings;
  final double averageRating;

  const TrainerStats({
    required this.totalClients,
    required this.pendingBookings,
    required this.upcomingBookings,
    required this.completedBookings,
    required this.totalEarnings,
    required this.averageRating,
  });

  factory TrainerStats.fromJson(Map<String, dynamic> json) => TrainerStats(
        totalClients: json['uniqueClients'] as int? ?? json['totalClients'] as int? ?? 0,
        pendingBookings: json['pendingBookings'] as int? ?? 0,
        upcomingBookings: json['upcomingBookings'] as int? ?? 0,
        completedBookings: json['completedBookings'] as int? ?? 0,
        totalEarnings: (json['totalRevenue'] as num?)?.toDouble() ?? (json['totalEarnings'] as num?)?.toDouble() ?? 0,
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      );

  factory TrainerStats.empty() => const TrainerStats(
        totalClients: 0,
        pendingBookings: 0,
        upcomingBookings: 0,
        completedBookings: 0,
        totalEarnings: 0,
        averageRating: 0,
      );
}

class TrainerBookingItem {
  final int id;
  final String bookingId;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? memberName;
  final String? memberAvatar;
  final String? serviceName;
  final String? notes;

  const TrainerBookingItem({
    required this.id,
    required this.bookingId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.memberName,
    this.memberAvatar,
    this.serviceName,
    this.notes,
  });

  factory TrainerBookingItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final svcReg = json['serviceRegistration'] as Map<String, dynamic>?;
    final svc = svcReg?['gymService'] as Map<String, dynamic>?;
    return TrainerBookingItem(
      id: json['id'] as int? ?? 0,
      bookingId: json['bookingId'] as String? ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      startTime: _trimSeconds(json['startTime'] as String? ?? ''),
      endTime: _trimSeconds(json['endTime'] as String? ?? ''),
      status: json['status'] as String? ?? '',
      memberName: user?['fullName'] as String?,
      memberAvatar: user?['avatar'] as String?,
      serviceName: svc?['name'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// "09:00:00" → "09:00"
  static String _trimSeconds(String t) {
    if (t.length == 8 && t[2] == ':' && t[5] == ':') return t.substring(0, 5);
    return t;
  }

  String get statusLabel {
    switch (status) {
      case 'CONFIRMED': return 'Confirmed';
      case 'PENDING':   return 'Pending confirmation';
      case 'CANCELLED': return 'Cancelled';
      case 'COMPLETED': return 'Completed';
      case 'REJECTED':  return 'Rejected';
      default:          return status;
    }
  }
}
