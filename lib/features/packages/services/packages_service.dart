import '../../../core/network/api.dart';
import '../../../core/storage/auth_storage.dart';
import '../models/package_model.dart';

/// ─── Packages API service ─────────────────────────────────────────────────────
class PackagesService {
  final AuthStorage _storage = AuthStorage();

  // GET /membership-packages/active — public
  Future<List<MembershipPackage>> getAvailablePackages() async {
    final res = await Api.public.get('/membership-packages/active');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list.map((e) => MembershipPackage.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET /user/memberships — user's purchased packages
  Future<List<Map<String, dynamic>>> getUserPackages() async {
    final res = await Api.private.get('/user/memberships');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list.cast<Map<String, dynamic>>();
  }

  // GET /user/memberships/active-packages — danh sách packageId đang active
  Future<Set<int>> getActivePackageIds() async {
    try {
      final res = await Api.private.get('/user/memberships/active-packages');
      final raw = (res.data as Map<String, dynamic>)['data'];
      if (raw == null) return {};
      final list = raw is List ? raw : [];
      return list.map((e) => (e as num).toInt()).toSet();
    } catch (_) {
      return {};
    }
  }
}
