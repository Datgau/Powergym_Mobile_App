import 'package:flutter/foundation.dart';
import '../../../../core/network/api.dart';
import '../models/earnings_model.dart';
import '../services/earnings_service.dart';

enum EarningsStatus { idle, loading, loaded, error }

class EarningsProvider extends ChangeNotifier {
  final EarningsService _service = EarningsService();

  EarningsStatus _status = EarningsStatus.idle;
  String _error = '';
  TrainerEarnings _earnings = TrainerEarnings.empty();

  EarningsStatus get status => _status;
  String get error => _error;
  TrainerEarnings get earnings => _earnings;
  bool get isLoading => _status == EarningsStatus.loading;

  Future<void> load(String trainerId) async {
    _status = EarningsStatus.loading;
    _error = '';
    notifyListeners();
    try {
      _earnings = await _service.getEarnings(trainerId);
      _status   = EarningsStatus.loaded;
    } catch (e) {
      _error  = Api.parseError(e);
      _status = EarningsStatus.error;
    }
    notifyListeners();
  }
}
