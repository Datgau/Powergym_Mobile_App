import 'api_client.dart';

class NotificationsService {
  final ApiClient _apiClient = ApiClient();

  // Get all notifications for user
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/notifications');
      final data = response.data;
      return List<Map<String, dynamic>>.from(data['notifications'] ?? []);
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _apiClient.put('/notifications/$notificationId/read');
      return true;
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead(String userId) async {
    try {
      await _apiClient.put('/users/$userId/notifications/read-all');
      return true;
    } catch (e) {
      throw Exception('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete('/notifications/$notificationId');
      return true;
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/notifications/unread-count');
      final data = response.data;
      return data['count'] ?? 0;
    } catch (e) {
      throw Exception('Error fetching unread count: $e');
    }
  }

  // Update notification settings
  Future<bool> updateNotificationSettings({
    required String userId,
    required Map<String, bool> settings,
  }) async {
    try {
      await _apiClient.put(
        '/users/$userId/notification-settings',
        data: settings,
      );
      return true;
    } catch (e) {
      throw Exception('Error updating notification settings: $e');
    }
  }
}
