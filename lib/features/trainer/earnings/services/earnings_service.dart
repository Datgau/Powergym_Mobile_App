import '../../../../core/network/api.dart';
import '../models/earnings_model.dart';

class EarningsService {
  /// GET /api/trainers/{trainerId}/salary
  Future<TrainerEarnings> getEarnings(String trainerId) async {
    try {
      final res = await Api.private.get('/trainers/$trainerId/salary');
      // TrainerSalaryController trả về trực tiếp TrainerSalaryResponse (không wrap ApiResponse)
      final data = res.data as Map<String, dynamic>;
      return TrainerEarnings.fromJson(data);
    } catch (_) {
      return TrainerEarnings.empty();
    }
  }
}
