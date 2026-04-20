// ── Booking item hiển thị trên trainer home ───────────────────────────────────
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

  /// Parse từ WebSocket payload (backend TrainerBookingResponse DTO)
  factory TrainerBookingItem.fromWebSocketJson(Map<String, dynamic> json) {
    // Backend DTO dùng nested user object và serviceName trực tiếp
    final user = json['user'] as Map<String, dynamic>?;
    return TrainerBookingItem(
      id: json['id'] as int? ?? 0,
      bookingId: json['bookingId'] as String? ?? '',
      bookingDate: _parseDate(json['bookingDate']),
      startTime: _parseTime(json['startTime']),
      endTime: _parseTime(json['endTime']),
      status: (json['status'] as String?) ?? '',
      memberName: user?['fullName'] as String?,
      memberAvatar: user?['avatar'] as String?,
      serviceName: json['serviceName'] as String?,
      notes: json['notes'] as String?,
    );
  }

  static String _parseDate(dynamic val) {
    if (val == null) return '';
    if (val is String) return val;
    if (val is List && val.length >= 3) {
      return '${val[0]}-${val[1].toString().padLeft(2, '0')}-${val[2].toString().padLeft(2, '0')}';
    }
    return val.toString();
  }

  static String _parseTime(dynamic val) {
    if (val == null) return '';
    if (val is String) return val;
    if (val is List && val.length >= 2) {
      return '${val[0].toString().padLeft(2, '0')}:${val[1].toString().padLeft(2, '0')}';
    }
    return val.toString();
  }

  String get statusLabel {
    switch (status) {
      case 'PENDING':   return 'Pending confirmation';
      case 'CONFIRMED': return 'Confirmed';
      case 'COMPLETED': return 'Completed';
      case 'CANCELLED': return 'Cancelled';
      case 'REJECTED':  return 'Rejected';
      default:          return status;
    }
  }
}

// ── Thống kê trainer ──────────────────────────────────────────────────────────
class TrainerStats {
  final int totalBookings;
  final int completedBookings;
  final int pendingBookings;
  final int upcomingBookings;
  final double totalEarnings;
  final double averageRating;

  const TrainerStats({
    required this.totalBookings,
    required this.completedBookings,
    required this.pendingBookings,
    required this.upcomingBookings,
    required this.totalEarnings,
    required this.averageRating,
  });

  factory TrainerStats.fromJson(Map<String, dynamic> json) => TrainerStats(
        totalBookings: json['totalBookings'] as int? ?? 0,
        completedBookings: json['completedBookings'] as int? ?? 0,
        pendingBookings: json['pendingBookings'] as int? ?? 0,
        upcomingBookings: json['upcomingBookings'] as int? ?? 0,
        totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      );

  factory TrainerStats.empty() => const TrainerStats(
        totalBookings: 0,
        completedBookings: 0,
        pendingBookings: 0,
        upcomingBookings: 0,
        totalEarnings: 0,
        averageRating: 0,
      );
}
