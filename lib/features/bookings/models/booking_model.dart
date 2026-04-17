/// ─── Booking models ───────────────────────────────────────────────────────────

class TrainerBooking {
  final int id;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? trainerName;
  final String? trainerAvatar;
  final String? serviceName;
  final String? notes;

  const TrainerBooking({
    required this.id,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.trainerName,
    this.trainerAvatar,
    this.serviceName,
    this.notes,
  });

  factory TrainerBooking.fromJson(Map<String, dynamic> json) {
    final trainer = json['trainer'] as Map<String, dynamic>?;
    final reg     = json['serviceRegistration'] as Map<String, dynamic>?;
    final svc     = reg?['gymService'] as Map<String, dynamic>?;

    return TrainerBooking(
      id:            json['id'] as int,
      bookingDate:   json['bookingDate'] as String? ?? '',
      startTime:     json['startTime'] as String? ?? '',
      endTime:       json['endTime'] as String? ?? '',
      status:        json['status'] as String? ?? '',
      trainerName:   trainer?['fullName'] as String?,
      trainerAvatar: trainer?['avatar'] as String?,
      serviceName:   svc?['name'] as String?,
      notes:         json['notes'] as String?,
    );
  }

  bool get isUpcoming => status == 'CONFIRMED' || status == 'PENDING';

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
}

class CreateBookingRequest {
  final int trainerId;
  final int serviceRegistrationId;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String? notes;

  const CreateBookingRequest({
    required this.trainerId,
    required this.serviceRegistrationId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'trainerId': trainerId,
        'serviceRegistrationId': serviceRegistrationId,
        'bookingDate': bookingDate,
        'startTime': startTime,
        'endTime': endTime,
        if (notes != null) 'notes': notes,
      };
}
