// Models cho luồng đăng ký dịch vụ

// ── Trainer ──────────────────────────────────────────────────────────────────
class TrainerForBooking {
  final int id;
  final String fullName;
  final String? avatar;
  final String? bio;
  final int? totalExperienceYears;
  final List<TrainerSpecialtyInfo> specialties;

  const TrainerForBooking({
    required this.id,
    required this.fullName,
    this.avatar,
    this.bio,
    this.totalExperienceYears,
    required this.specialties,
  });

  factory TrainerForBooking.fromJson(Map<String, dynamic> json) {
    return TrainerForBooking(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      totalExperienceYears: json['totalExperienceYears'] != null
          ? (json['totalExperienceYears'] as num).toInt()
          : null,
      specialties: (json['specialties'] as List<dynamic>? ?? [])
          .map((e) => TrainerSpecialtyInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String get specialtyLabels {
    if (specialties.isEmpty) return 'Đa năng';
    return specialties
        .map((s) => s.specialty.displayName ?? s.specialty.name)
        .take(2)
        .join(', ');
  }
}

class TrainerSpecialtyInfo {
  final int id;
  final SpecialtyCategory specialty;
  final int? experienceYears;
  final String? level;

  const TrainerSpecialtyInfo({
    required this.id,
    required this.specialty,
    this.experienceYears,
    this.level,
  });

  factory TrainerSpecialtyInfo.fromJson(Map<String, dynamic> json) {
    return TrainerSpecialtyInfo(
      id: (json['id'] as num).toInt(),
      specialty: SpecialtyCategory.fromJson(
          json['specialty'] as Map<String, dynamic>),
      experienceYears: json['experienceYears'] != null
          ? (json['experienceYears'] as num).toInt()
          : null,
      level: json['level'] as String?,
    );
  }
}

class SpecialtyCategory {
  final int id;
  final String name;
  final String? displayName;

  const SpecialtyCategory(
      {required this.id, required this.name, this.displayName});

  factory SpecialtyCategory.fromJson(Map<String, dynamic> json) {
    return SpecialtyCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
    );
  }
}

// ── Time slot ────────────────────────────────────────────────────────────────
class TimeSlot {
  final String startTime; // "07:00"
  final String endTime;   // "08:00"
  final String label;

  const TimeSlot(
      {required this.startTime, required this.endTime, required this.label});
}

// Các khung giờ cố định (giống web)
const kBookingSlots = [
  TimeSlot(startTime: '07:00', endTime: '08:00', label: '07:00 - 08:00'),
  TimeSlot(startTime: '08:00', endTime: '09:00', label: '08:00 - 09:00'),
  TimeSlot(startTime: '09:00', endTime: '10:00', label: '09:00 - 10:00'),
  TimeSlot(startTime: '10:00', endTime: '11:00', label: '10:00 - 11:00'),
  TimeSlot(startTime: '14:00', endTime: '15:00', label: '14:00 - 15:00'),
  TimeSlot(startTime: '15:00', endTime: '16:00', label: '15:00 - 16:00'),
  TimeSlot(startTime: '16:00', endTime: '17:00', label: '16:00 - 17:00'),
  TimeSlot(startTime: '17:00', endTime: '18:00', label: '17:00 - 18:00'),
  TimeSlot(startTime: '18:00', endTime: '19:00', label: '18:00 - 19:00'),
  TimeSlot(startTime: '19:00', endTime: '20:00', label: '19:00 - 20:00'),
];

// ── Booking data tổng hợp sau khi user chọn xong ─────────────────────────────
class ServiceBookingData {
  final TrainerForBooking? trainer;
  final DateTime startDate;
  final TimeSlot slot;

  const ServiceBookingData({
    this.trainer,
    required this.startDate,
    required this.slot,
  });
}

// ── Response đăng ký dịch vụ ─────────────────────────────────────────────────
class ServiceRegistrationResponse {
  final int id;
  final String status;

  const ServiceRegistrationResponse({required this.id, required this.status});

  factory ServiceRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return ServiceRegistrationResponse(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? 'PENDING',
    );
  }
}
