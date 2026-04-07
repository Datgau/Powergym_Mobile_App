import 'api_client.dart';

class HomeService {
  final ApiClient _apiClient = ApiClient();

  // Get user stats (sessions, streak, remaining sessions)
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/stats');
      return response.data;
    } catch (e) {
      throw Exception('Error fetching user stats: $e');
    }
  }

  // Get upcoming bookings
  Future<List<Map<String, dynamic>>> getUpcomingBookings(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/bookings/upcoming');
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['bookings'] ?? []);
    } catch (e) {
      throw Exception('Error fetching upcoming bookings: $e');
    }
  }

  // Get user profile summary
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/profile');
      return response.data;
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }
}
