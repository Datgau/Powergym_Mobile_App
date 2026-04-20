import '../../../../core/network/api.dart';
import '../models/trainer_home_models.dart';

class TrainerHomeService {
  /// GET /api/trainer/{id}/bookings/pending
  Future<List<TrainerBookingItem>> getPendingBookings(String trainerId) async {
    final res = await Api.private.get('/trainer/$trainerId/bookings/pending');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list.map((e) => TrainerBookingItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/trainer/{id}/bookings/upcoming
  Future<List<TrainerBookingItem>> getUpcomingBookings(String trainerId) async {
    final res = await Api.private.get('/trainer/$trainerId/bookings/upcoming');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list.map((e) => TrainerBookingItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/trainer-management/trainer/{id}/statistics
  Future<TrainerStats> getStatistics(String trainerId) async {
    try {
      final res = await Api.private.get('/trainer-management/trainer/$trainerId/statistics');
      final data = (res.data as Map<String, dynamic>)['data'];
      if (data == null) return TrainerStats.empty();
      return TrainerStats.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return TrainerStats.empty();
    }
  }

  /// GET /api/trainers/{trainerId}/salary
  /// Returns salary information (excluding rejected/cancelled bookings)
  Future<TrainerSalaryData> getSalary(String trainerId) async {
    try {
      final res = await Api.private.get('/trainers/$trainerId/salary');
      final data = res.data;
      
      // Handle both wrapped and unwrapped responses
      final salaryData = data is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>? ?? data)
          : <String, dynamic>{};
      
      return TrainerSalaryData.fromJson(salaryData);
    } catch (e) {
      print('Error fetching trainer salary: $e');
      return TrainerSalaryData.empty();
    }
  }

  /// Accept booking: PUT /api/trainer/{trainerId}/bookings/{bookingId}/accept
  Future<void> acceptBooking(String trainerId, String bookingId, {String? notes}) async {
    await Api.private.put(
      '/trainer/$trainerId/bookings/$bookingId/accept',
      queryParameters: notes != null ? {'notes': notes} : null,
    );
  }

  /// Reject booking: POST /api/trainer/{trainerId}/bookings/{bookingId}/reject
  Future<void> rejectBooking(String trainerId, String bookingId, String reason) async {
    await Api.private.post(
      '/trainer/$trainerId/bookings/$bookingId/reject',
      data: {'rejectionReason': reason},
    );
  }

  /// Submit leave request: POST /api/trainer-leave-requests/trainer/{trainerId}
  Future<void> submitLeaveRequest({
    required int trainerId,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    await Api.private.post(
      '/trainer-leave-requests/trainer/$trainerId',
      data: {
        'startDate': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD
        'endDate': endDate.toIso8601String().split('T')[0],
        'reason': reason,
      },
    );
  }
}
