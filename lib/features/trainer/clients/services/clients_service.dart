import '../../../../core/network/api.dart';
import '../models/client_model.dart';

class ClientsService {
  /// GET /api/service-registrations/my-clients
  /// Backend: EnhancedServiceRegistrationService.getTrainerRegistrations(trainerId)
  Future<List<ClientModel>> getMyClients() async {
    final res = await Api.private.get('/service-registrations/my-clients');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list
        .map((e) => ClientModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
