import '../../../core/network/api.dart';
import '../../../core/storage/auth_storage.dart';
import '../models/booking_model.dart';

/// ─── Bookings API service ─────────────────────────────────────────────────────
class BookingsService {
  final AuthStorage _storage = AuthStorage();

  // GET /bookings/user/{userId}
  Future<List<TrainerBooking>> getMyBookings({String? status}) async {
    final userId = await _storage.getUserId();
    if (userId == null) return [];

    final res = await Api.private.get(
      '/bookings/user/$userId',
      queryParameters: status != null ? {'status': status} : null,
    );
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list.map((e) => TrainerBooking.fromJson(e as Map<String, dynamic>)).toList();
  }

  // POST /bookings/user/{userId}
  Future<TrainerBooking> createBooking(CreateBookingRequest request) async {
    final userId = await _storage.getUserId();
    final res = await Api.private.post(
      '/bookings/user/$userId',
      data: request.toJson(),
    );
    return TrainerBooking.fromJson(
      (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>,
    );
  }

  // PUT /bookings/{bookingId}/cancel
  Future<void> cancelBooking(int bookingId, {String? reason}) async {
    final userId = await _storage.getUserId();
    await Api.private.put(
      '/bookings/$bookingId/cancel',
      data: null,
      queryParameters: {
        'userId': userId,
        if (reason != null) 'reason': reason,
      },
    );
  }

  // GET /trainers — public list of active trainers
  Future<List<Map<String, dynamic>>> getAvailableTrainers() async {
    final res = await Api.public.get('/trainers');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list.cast<Map<String, dynamic>>();
  }
}
