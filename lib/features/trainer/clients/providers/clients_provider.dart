import 'package:flutter/foundation.dart';
import '../../../../core/network/api.dart';
import '../models/client_model.dart';
import '../services/clients_service.dart';

enum ClientsStatus { idle, loading, loaded, error }

class ClientsProvider extends ChangeNotifier {
  final ClientsService _service = ClientsService();

  ClientsStatus _status = ClientsStatus.idle;
  String _error = '';
  List<ClientModel> _clients = [];
  String _searchQuery = '';

  ClientsStatus get status => _status;
  String get error => _error;
  bool get isLoading => _status == ClientsStatus.loading;

  List<ClientModel> get clients {
    if (_searchQuery.isEmpty) return _clients;
    final q = _searchQuery.toLowerCase();
    return _clients.where((c) =>
        c.fullName.toLowerCase().contains(q) ||
        c.email.toLowerCase().contains(q) ||
        c.serviceName.toLowerCase().contains(q)).toList();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> load(String trainerId) async {
    _status = ClientsStatus.loading;
    _error = '';
    notifyListeners();
    try {
      _clients = await _service.getMyClients();
      _status  = ClientsStatus.loaded;
    } catch (e) {
      _error  = Api.parseError(e);
      _status = ClientsStatus.error;
    }
    notifyListeners();
  }
}
