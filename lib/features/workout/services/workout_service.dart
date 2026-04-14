import '../../../core/network/api.dart';
import '../models/user_membership.dart';
import '../models/user_service_registration.dart';

class WorkoutService {
  /// GET /api/user/memberships/active
  Future<List<UserMembership>> getActiveMemberships() async {
    final res = await Api.private.get('/user/memberships/active');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list
        .map((e) => UserMembership.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// GET /api/user/service-registrations/active
  Future<List<UserServiceRegistration>> getActiveServiceRegistrations() async {
    final res = await Api.private.get('/user/service-registrations/active');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list
        .map((e) =>
            UserServiceRegistration.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
