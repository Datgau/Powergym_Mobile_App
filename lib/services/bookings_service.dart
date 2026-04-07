import 'api_client.dart';

class BookingsService {
  final ApiClient _apiClient = ApiClient();

  // Get all bookings for user
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/bookings');
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['bookings'] ?? []);
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  // Create new booking
  Future<Map<String, dynamic>> createBooking({
    required String userId,
    required String trainerId,
    required String date,
    required String time,
  }) async {
    try {
      final response = await _apiClient.post(
        '/bookings',
        data: {
          'userId': userId,
          'trainerId': trainerId,
          'date': date,
          'time': time,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _apiClient.delete('/bookings/$bookingId');
      return true;
    } catch (e) {
      throw Exception('Error canceling booking: $e');
    }
  }

  // Get available trainers
  Future<List<Map<String, dynamic>>> getAvailableTrainers() async {
    try {
      final response = await _apiClient.get('/trainers/available');
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['trainers'] ?? []);
    } catch (e) {
      throw Exception('Error fetching trainers: $e');
    }
  }
}
