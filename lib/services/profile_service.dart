import 'package:powergym_mobile_app/core/network/api.dart';

class ProfileService {
  

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await Api.private.get('/users/$userId/profile');
      return response.data;
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final response = await Api.private.put(
        '/users/$userId/profile',
        data: profileData,
      );
      return response.data;
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  // Get user achievements
  Future<List<Map<String, dynamic>>> getUserAchievements(String userId) async {
    try {
      final response = await Api.private.get('/users/$userId/achievements');
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['achievements'] ?? []);
    } catch (e) {
      throw Exception('Error fetching achievements: $e');
    }
  }

  // Get favorite trainers
  Future<List<Map<String, dynamic>>> getFavoriteTrainers(String userId) async {
    try {
      final response = await Api.private.get('/users/$userId/trainers/favorites');
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['trainers'] ?? []);
    } catch (e) {
      throw Exception('Error fetching favorite trainers: $e');
    }
  }

  // Update body metrics
  Future<Map<String, dynamic>> updateBodyMetrics({
    required String userId,
    required double weight,
    required double height,
  }) async {
    try {
      final response = await Api.private.put(
        '/users/$userId/metrics',
        data: {
          'weight': weight,
          'height': height,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Error updating body metrics: $e');
    }
  }

  // Update fitness goals
  Future<Map<String, dynamic>> updateFitnessGoals({
    required String userId,
    required Map<String, dynamic> goals,
  }) async {
    try {
      final response = await Api.private.put(
        '/users/$userId/goals',
        data: goals,
      );
      return response.data;
    } catch (e) {
      throw Exception('Error updating fitness goals: $e');
    }
  }
}
