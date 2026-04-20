import 'package:flutter/foundation.dart';
import 'package:powergym_mobile_app/core/network/api.dart';
import '../data/models/home_models.dart';
import '../data/services/home_api_service.dart';

enum HomeStatus { idle, loading, loaded, error }

class HomeProvider extends ChangeNotifier {
  final HomeApiService _api = HomeApiService();

  HomeStatus _status = HomeStatus.idle;
  String _error = '';

  UserProfile? _profile;
  List<TrainerBookingItem> _bookings = [];
  List<MembershipPackageItem> _packages = [];
  List<ServiceRegistrationItem> _serviceRegistrations = [];
  List<ActiveMembershipItem> _activeMemberships = [];

  HomeStatus get status => _status;
  String get error => _error;
  UserProfile? get profile => _profile;
  List<TrainerBookingItem> get bookings => _bookings;
  List<TrainerBookingItem> get upcomingBookings =>
      _bookings.where((b) => b.isUpcoming).take(3).toList();
  List<MembershipPackageItem> get packages => _packages;
  List<ServiceRegistrationItem> get serviceRegistrations => _serviceRegistrations;
  List<ActiveMembershipItem> get activeMemberships => _activeMemberships;
  int get activeServiceCount => _serviceRegistrations.where((s) => s.isActive).length;
  int get activeMembershipCount => _activeMemberships.length;
  bool get isLoading => _status == HomeStatus.loading;

  Future<void> loadAll() async {
    _status = HomeStatus.loading;
    _error = '';
    notifyListeners();

    try {
      _profile = await _api.getProfile();
      _bookings = await _api.getMyBookings();
      _packages = await _api.getActivePackages();
      _serviceRegistrations = await _api.getMyServiceRegistrations();
      // Active memberships — non-fatal if it fails
      try {
        _activeMemberships = await _api.getMyActiveMemberships();
      } catch (e) {
        _activeMemberships = [];
        debugPrint('[HomeProvider] getMyActiveMemberships failed: $e');
      }
      _status = HomeStatus.loaded;
    } catch (e) {
      _error = Api.parseError(e);
      _status = HomeStatus.error;
    }

    notifyListeners();
  }

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
