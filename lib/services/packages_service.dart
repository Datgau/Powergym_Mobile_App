import 'api_client.dart';

class PackagesService {
  final ApiClient _apiClient = ApiClient();

  // Get user's active packages
  Future<List<Map<String, dynamic>>> getUserPackages(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/packages');
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['packages'] ?? []);
    } catch (e) {
      throw Exception('Error fetching user packages: $e');
    }
  }

  // Get available packages for purchase
  Future<List<Map<String, dynamic>>> getAvailablePackages() async {
    try {
      final response = await _apiClient.get('/packages');
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['packages'] ?? []);
    } catch (e) {
      throw Exception('Error fetching available packages: $e');
    }
  }

  // Purchase package
  Future<Map<String, dynamic>> purchasePackage({
    required String userId,
    required String packageId,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiClient.post(
        '/packages/purchase',
        data: {
          'userId': userId,
          'packageId': packageId,
          'paymentMethod': paymentMethod,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Error purchasing package: $e');
    }
  }

  // Get package history
  Future<List<Map<String, dynamic>>> getPackageHistory(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/packages/history');
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['history'] ?? []);
    } catch (e) {
      throw Exception('Error fetching package history: $e');
    }
  }

  // Renew package
  Future<Map<String, dynamic>> renewPackage({
    required String userId,
    required String packageId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/packages/renew',
        data: {
          'userId': userId,
          'packageId': packageId,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Error renewing package: $e');
    }
  }
}
