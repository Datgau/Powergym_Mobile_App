import 'package:powergym_mobile_app/core/network/api.dart';
import 'package:powergym_mobile_app/core/storage/auth_storage.dart';
import '../models/home_models.dart';

class HomeApiService {
  final AuthStorage _storage = AuthStorage();

  // ─── Profile ──────────────────────────────────────────────────────────────
  Future<UserProfile> getProfile() async {
    final res = await Api.private.get('/user/profile');
    final data = (res.data as Map<String, dynamic>)['data'];
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  // ─── Bookings — GET /bookings/user/{userId} ───────────────────────────────
  Future<List<TrainerBookingItem>> getMyBookings() async {
    final userId = await _storage.getUserId();
    if (userId == null) return [];

    final res = await Api.private.get('/bookings/user/$userId');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list
        .map((e) => TrainerBookingItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Membership packages (public) ─────────────────────────────────────────
  Future<List<MembershipPackageItem>> getActivePackages() async {
    final res = await Api.public.get('/membership-packages/active');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list
        .map((e) => MembershipPackageItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── User's service registrations ─────────────────────────────────────────
  Future<List<ServiceRegistrationItem>> getMyServiceRegistrations() async {
    final res = await Api.private.get('/service-registrations/my-registrations');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : [];
    return list
        .map((e) => ServiceRegistrationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── User's active memberships ────────────────────────────────────────────
  Future<List<ActiveMembershipItem>> getMyActiveMemberships() async {
    final res = await Api.private.get('/user/memberships/active');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : [];
    return list
        .map((e) => ActiveMembershipItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}