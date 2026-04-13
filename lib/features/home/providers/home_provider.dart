import 'package:flutter/foundation.dart';
import '../data/models/home_models.dart';
import '../data/services/home_api_service.dart';
import '../../../services/api.dart';

enum HomeStatus { idle, loading, loaded, error }

class HomeProvider extends ChangeNotifier {
  final HomeApiService _api = HomeApiService();

  HomeStatus _status = HomeStatus.idle;
  String _error = '';

  UserProfile? _profile;
  List<TrainerBookingItem> _bookings = [];
  List<MembershipPackageItem> _packages = [];

  HomeStatus get status => _status;
  String get error => _error;
  UserProfile? get profile => _profile;
  List<TrainerBookingItem> get bookings => _bookings;
  List<TrainerBookingItem> get upcomingBookings =>
      _bookings.where((b) => b.isUpcoming).take(3).toList();
  List<MembershipPackageItem> get packages => _packages;
  bool get isLoading => _status == HomeStatus.loading;

  // ─── Load all home data in parallel ──────────────────────────────────────

  Future<void> loadAll() async {
    _status = HomeStatus.loading;
    _error = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getProfile(),
        _api.getMyBookings(),
        _api.getActivePackages(),
      ]);

      _profile = results[0] as UserProfile;
      _bookings = results[1] as List<TrainerBookingItem>;
      _packages = results[2] as List<MembershipPackageItem>;
      _status = HomeStatus.loaded;
    } catch (e) {
      _error = Api.parseError(e);
      _status = HomeStatus.error;
    }

    notifyListeners();
  }

  // ─── Refresh individual sections ─────────────────────────────────────────

  Future<void> refreshBookings() async {
    try {
      _bookings = await _api.getMyBookings();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> refreshProfile() async {
    try {
      _profile = await _api.getProfile();
      notifyListeners();
    } catch (_) {}
  }
}
