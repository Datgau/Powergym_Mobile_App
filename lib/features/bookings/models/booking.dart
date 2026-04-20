class TrainerBooking {
  final int id;
  final String bookingId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? notes;
  final User user;
  final User? trainer;
  final GymService? service;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  
  TrainerBooking({
    required this.id,
    required this.bookingId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
    required this.user,
    this.trainer,
    this.service,
    required this.createdAt,
    this.confirmedAt,
    this.rejectedAt,
    this.rejectionReason,
  });
  
  factory TrainerBooking.fromJson(Map<String, dynamic> json) {
    return TrainerBooking(
      id: json['id'] as int,
      bookingId: json['bookingId'] as String,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      trainer: json['trainer'] != null 
          ? User.fromJson(json['trainer'] as Map<String, dynamic>) 
          : null,
      service: json['service'] != null 
          ? GymService.fromJson(json['service'] as Map<String, dynamic>) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      confirmedAt: json['confirmedAt'] != null 
          ? DateTime.parse(json['confirmedAt'] as String) 
          : null,
      rejectedAt: json['rejectedAt'] != null 
          ? DateTime.parse(json['rejectedAt'] as String) 
          : null,
      rejectionReason: json['rejectionReason'] as String?,
    );
  }
  
  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
  bool get isRejected => status == 'REJECTED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isCompleted => status == 'COMPLETED';
  
  String get statusText {
    switch (status) {
      case 'PENDING':
        return 'Pending';
      case 'CONFIRMED':
        return 'Confirm';
      case 'REJECTED':
        return 'Rejected';
      case 'CANCELLED':
        return 'Cancelled';
      case 'COMPLETED':
        return 'Completed';
      default:
        return status;
    }
  }
}

class User {
  final int id;
  final String username;
  final String? fullName;
  final String? email;
  
  User({
    required this.id,
    required this.username,
    this.fullName,
    this.email,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String?,
    );
  }
}

class GymService {
  final int id;
  final String name;
  final String? description;
  final double price;
  
  GymService({
    required this.id,
    required this.name,
    this.description,
    required this.price,
  });
  
  factory GymService.fromJson(Map<String, dynamic> json) {
    return GymService(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
    );
  }
}
