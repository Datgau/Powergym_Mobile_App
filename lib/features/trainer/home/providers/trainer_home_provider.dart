import 'package:flutter/foundation.dart';
import '../../../../core/network/api.dart';
import '../models/trainer_home_models.dart';
import '../services/trainer_home_service.dart';

enum TrainerHomeStatus { idle, loading, loaded, error }

class TrainerHomeProvider extends ChangeNotifier {
  final TrainerHomeService _service = TrainerHomeService();

  TrainerHomeStatus _status = TrainerHomeStatus.idle;
  String _error = '';
  TrainerStats _stats = TrainerStats.empty();
  List<TrainerBookingItem> _pending = [];
  List<TrainerBookingItem> _upcoming = [];

  TrainerHomeStatus get status => _status;
  String get error => _error;
  TrainerStats get stats => _stats;
  List<TrainerBookingItem> get pendingBookings => _pending;
  List<TrainerBookingItem> get upcomingBookings => _upcoming;
  bool get isLoading => _status == TrainerHomeStatus.loading;

  Future<void> loadAll(String trainerId) async {
    _status = TrainerHomeStatus.loading;
    _error = '';
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getPendingBookings(trainerId),
        _service.getUpcomingBookings(trainerId),
        _service.getStatistics(trainerId),
      ]);
      _pending  = results[0] as List<TrainerBookingItem>;
      _upcoming = results[1] as List<TrainerBookingItem>;
      _stats    = results[2] as TrainerStats;
      _status   = TrainerHomeStatus.loaded;
    } catch (e) {
      _error  = Api.parseError(e);
      _status = TrainerHomeStatus.error;
    }
    notifyListeners();
  }

  Future<void> acceptBooking(String trainerId, String bookingId) async {
    try {
      await _service.acceptBooking(trainerId, bookingId);
      await loadAll(trainerId);
    } catch (e) {
      _error = Api.parseError(e);
      notifyListeners();
    }
  }

  Future<void> rejectBooking(String trainerId, String bookingId, String reason) async {
    try {
      await _service.rejectBooking(trainerId, bookingId, reason);
      await loadAll(trainerId);
    } catch (e) {
      _error = Api.parseError(e);
      notifyListeners();
    }
  }
}
