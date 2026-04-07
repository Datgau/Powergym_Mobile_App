class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String userProfileEndpoint = '/user/profile';
  static const String membershipPackagesEndpoint = '/membership-packages/active';
  static const String trainerBookingsEndpoint = '/trainer-bookings';
  static const String myBookingsEndpoint = '/user/bookings';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String userNameKey = 'user_name';
  
  // User Roles
  static const String roleUser = 'USER';
  static const String roleTrainer = 'TRAINER';
  static const String roleAdmin = 'ADMIN';
  
  // Booking Status
  static const String statusPending = 'PENDING';
  static const String statusConfirmed = 'CONFIRMED';
  static const String statusRejected = 'REJECTED';
  static const String statusCancelled = 'CANCELLED';
  static const String statusCompleted = 'COMPLETED';
  
  // Payment Types
  static const String paymentMomo = 'MOMO';
  static const String paymentBank = 'BANK_TRANSFER';
  
  // Time Slots (giờ mở cửa phòng gym)
  static const List<String> timeSlots = [
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00', '21:00', '22:00',
  ];
  
  // Session Duration (phút)
  static const int sessionDuration = 60;

  static String get apiBaseUrl => null;
}
