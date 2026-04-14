/// Booking của trainer trong một ngày cụ thể
class DayBooking {
  final int id;
  final String bookingId;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status; // PENDING, CONFIRMED, COMPLETED, CANCELLED, REJECTED
  final String memberName;
  final String? memberAvatar;
  final String? serviceName;
  final String? notes;

  const DayBooking({
    required this.id,
    required this.bookingId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.memberName,
    this.memberAvatar,
    this.serviceName,
    this.notes,
  });

  factory DayBooking.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final svcReg = json['serviceRegistration'] as Map<String, dynamic>?;
    final svc = svcReg?['gymService'] as Map<String, dynamic>?;
    return DayBooking(
      id: json['id'] as int? ?? 0,
      bookingId: json['bookingId'] as String? ?? '',
      bookingDate: json['bookingDate'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      status: json['status'] as String? ?? '',
      memberName: user?['fullName'] as String? ?? 'Học viên',
      memberAvatar: user?['avatar'] as String?,
      serviceName: svc?['name'] as String?,
      notes: json['notes'] as String?,
    );
  }

  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED' || status == 'REJECTED';

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
