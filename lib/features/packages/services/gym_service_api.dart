import '../../../core/network/api.dart';
import '../models/gym_service_model.dart';

class GymServiceApi {
  /// GET /gym/services/active — public, không cần auth
  Future<List<GymService>> getActiveServices() async {
    final res = await Api.public.get('/gym/services/active');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list
        .map((e) => GymService.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
