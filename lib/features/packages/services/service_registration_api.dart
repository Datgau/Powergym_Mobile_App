import '../../../core/network/api.dart';
import '../../../core/storage/auth_storage.dart';
import '../models/service_registration_models.dart';

class ServiceRegistrationApi {
  final AuthStorage _storage = AuthStorage();

  // ── GET /public/trainers/specialty-category/{serviceId} ──────────────────
  Future<List<TrainerForBooking>> getTrainersByService(int serviceId) async {
    final res =
        await Api.public.get('/public/trainers/specialty-category/$serviceId');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list
        .map((e) => TrainerForBooking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── POST /service-registrations ──────────────────────────────────────────
  // registrationType: 'ONLINE' | 'COUNTER'
  Future<ServiceRegistrationResponse> registerService({
    required int serviceId,
    required String registrationType,
    String? notes,
  }) async {
    final res = await Api.private.post('/service-registrations', data: {
      'serviceId': serviceId,
      'registrationType': registrationType,
      if (notes != null) 'notes': notes,
    });
    final data =
        (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    return ServiceRegistrationResponse.fromJson(data);
  }

  // ── GET /service-registrations/my-registrations ──────────────────────────
  // Tìm registration ACTIVE của service sau khi webhook kích hoạt
  Future<ServiceRegistrationResponse?> findActiveRegistration(
      int serviceId, int? pendingRegistrationId) async {
    final res =
        await Api.private.get('/service-registrations/my-registrations');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return null;
    final list = raw is List ? raw : (raw['content'] as List? ?? []);

    for (final item in list) {
      final map = item as Map<String, dynamic>;
      final id = (map['id'] as num?)?.toInt();
      final status = (map['status'] as String? ?? '').toUpperCase();
      final svcId =
          ((map['service'] as Map<String, dynamic>?)?['id'] as num?)?.toInt();

      // Ưu tiên match theo pendingRegistrationId nếu có
      if (pendingRegistrationId != null && id == pendingRegistrationId && status == 'ACTIVE') {
        return ServiceRegistrationResponse(id: id!, status: status);
      }
      // Fallback: match theo serviceId
      if (pendingRegistrationId == null && svcId == serviceId && status == 'ACTIVE') {
        return ServiceRegistrationResponse(id: id!, status: status);
      }
    }
    return null;
  }

  // ── POST /bookings/user/{userId} ─────────────────────────────────────────
  Future<void> createBooking({
    required int serviceRegistrationId,
    required int? trainerId,
    required String bookingDate, // "yyyy-MM-dd"
    required String startTime,   // "07:00"
    required String endTime,     // "08:00"
  }) async {
    final userIdStr = await _storage.getUserId();
    if (userIdStr == null) throw Exception('Chưa đăng nhập');
    final userId = int.parse(userIdStr);

    await Api.private.post('/bookings/user/$userId', data: {
      'serviceRegistrationId': serviceRegistrationId,
      if (trainerId != null) 'trainerId': trainerId,
      'bookingDate': bookingDate,
      'startTime': startTime,
      'endTime': endTime,
      'sessionType': 'REGULAR',
    });
  }
}
