import '../../../core/network/api.dart';
import '../models/trainer_models.dart';

class TrainerService {
  /// GET /api/trainer/{id}/bookings/pending
  Future<List<TrainerBookingItem>> getPendingBookings(String trainerId) async {
    final res = await Api.private.get('/trainer/$trainerId/bookings/pending');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list
        .map((e) => TrainerBookingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/trainer/{id}/bookings/upcoming
  Future<List<TrainerBookingItem>> getUpcomingBookings(String trainerId) async {
    final res = await Api.private.get('/trainer/$trainerId/bookings/upcoming');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list
        .map((e) => TrainerBookingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/trainer-management/trainer/{id}/statistics
  Future<TrainerStats> getStatistics(String trainerId) async {
    try {
      final res = await Api.private
          .get('/trainer-management/trainer/$trainerId/statistics');
      final data = (res.data as Map<String, dynamic>)['data'];
      if (data == null) return TrainerStats.empty();
      return TrainerStats.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return TrainerStats.empty();
    }
  }
}
