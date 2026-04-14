class UserServiceRegistration {
  final int id;
  final String status;
  final DateTime registrationDate;
  final DateTime? expirationDate;
  final WorkoutGymService gymService;
  final WorkoutTrainer? trainer;
  final List<ServiceBooking> bookings;

  const UserServiceRegistration({
    required this.id,
    required this.status,
    required this.registrationDate,
    this.expirationDate,
    required this.gymService,
    this.trainer,
    required this.bookings,
  });

  factory UserServiceRegistration.fromJson(Map<String, dynamic> json) {
    final svc = json['gymService'] as Map<String, dynamic>? ?? {};
    final trainerJson = json['trainer'] as Map<String, dynamic>?;
    final bookingsRaw = json['bookings'] as List<dynamic>? ?? [];

    return UserServiceRegistration(
      id: json['id'] as int,
      status: json['status'] as String? ?? 'ACTIVE',
      registrationDate: DateTime.parse(json['registrationDate'] as String),
      expirationDate: json['expirationDate'] != null &&
              (json['expirationDate'] as String).isNotEmpty
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      gymService: WorkoutGymService.fromJson(svc),
      trainer: (trainerJson != null && trainerJson.isNotEmpty)
          ? WorkoutTrainer.fromJson(trainerJson)
          : null,
      bookings: bookingsRaw
          .map((e) => ServiceBooking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isActive => status == 'ACTIVE';

  int get daysRemaining {
    if (expirationDate == null) return 0;
    return expirationDate!.difference(DateTime.now()).inDays.clamp(0, 9999);
  }

  int get daysElapsed {
    final now = DateTime.now();
    final end = expirationDate != null && now.isAfter(expirationDate!)
        ? expirationDate!
        : now;
    return end.difference(registrationDate).inDays.clamp(0, duration);
  }

  int get duration => gymService.duration;

  double get progressPercent =>
      duration > 0 ? (daysElapsed / duration).clamp(0.0, 1.0) : 0;

  /// Ngày có lịch tập (booking confirmed/completed)
  Set<DateTime> get bookedDays {
    return {
      for (final b in bookings)
        if (b.bookingDate != null)
          DateTime(b.bookingDate!.year, b.bookingDate!.month, b.bookingDate!.day)
    };
  }
}

class WorkoutGymService {
  final int id;
  final String name;
  final String description;
  final int duration;
  final double price;

  const WorkoutGymService({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
  });

  factory WorkoutGymService.fromJson(Map<String, dynamic> json) =>
      WorkoutGymService(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        duration: json['duration'] as int? ?? 30,
        price: (json['price'] as num?)?.toDouble() ?? 0,
      );
}

class WorkoutTrainer {
  final int id;
  final String fullName;
  final String? avatar;

  const WorkoutTrainer(
      {required this.id, required this.fullName, this.avatar});

  factory WorkoutTrainer.fromJson(Map<String, dynamic> json) => WorkoutTrainer(
        id: json['id'] as int? ?? 0,
        fullName: json['fullName'] as String? ?? '',
        avatar: json['avatar'] as String?,
      );
}

class ServiceBooking {
  final int id;
  final DateTime? bookingDate;
  final String startTime;
  final String endTime;
  final String status;

  const ServiceBooking({
    required this.id,
    this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory ServiceBooking.fromJson(Map<String, dynamic> json) {
    final dateStr = json['bookingDate'] as String?;
    return ServiceBooking(
      id: json['id'] as int? ?? 0,
      bookingDate:
          (dateStr != null && dateStr.isNotEmpty) ? DateTime.parse(dateStr) : null,
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}
