import '../../clients/models/client_model.dart';

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
        totalClients: json['totalClients'] as int? ?? 0,
        pendingBookings: json['pendingBookings'] as int? ?? 0,
        upcomingBookings: json['upcomingBookings'] as int? ?? 0,
        completedBookings: json['completedBookings'] as int? ?? 0,
        totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
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
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      status: json['status'] as String? ?? '',
      memberName: user?['fullName'] as String?,
      memberAvatar: user?['avatar'] as String?,
      serviceName: svc?['name'] as String?,
      notes: json['notes'] as String?,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'PENDING':   return 'Chờ xác nhận';
      case 'CONFIRMED': return 'Đã xác nhận';
      case 'COMPLETED': return 'Hoàn thành';
      case 'CANCELLED': return 'Đã hủy';
      case 'REJECTED':  return 'Đã từ chối';
      default:          return status;
    }
  }
}
