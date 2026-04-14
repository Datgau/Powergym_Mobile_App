import '../../../../core/network/api.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  /// GET /api/trainer/{trainerId}/bookings/upcoming — tất cả booking sắp tới
  Future<List<DayBooking>> getUpcomingBookings(String trainerId) async {
    final res = await Api.private.get('/trainer/$trainerId/bookings/upcoming');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list.map((e) => DayBooking.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// GET /api/trainer/{trainerId}/bookings/pending — booking chờ xác nhận
  Future<List<DayBooking>> getPendingBookings(String trainerId) async {
    final res = await Api.private.get('/trainer/$trainerId/bookings/pending');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list.map((e) => DayBooking.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// PUT /api/trainer/{trainerId}/bookings/{bookingId}/accept
  Future<void> acceptBooking(String trainerId, String bookingId) async {
    await Api.private.put('/trainer/$trainerId/bookings/$bookingId/accept');
  }
}
