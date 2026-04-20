import '../../../core/network/api.dart';
import '../models/notification_model.dart';

/// Gym notifications REST API service
class NotificationsService {

  // GET /gym-notifications
  Future<List<AppNotification>> getNotifications() async {
    final res = await Api.private.get('/gym-notifications');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET /gym-notifications/unread-count
  Future<int> getUnreadCount() async {
    try {
      final res = await Api.private.get('/gym-notifications/unread-count');
      final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
      return (data?['count'] as num? ?? 0).toInt();
    } catch (_) {
      return 0;
    }
  }

  // PUT /gym-notifications/{id}/read
  Future<void> markAsRead(int notificationId) async {
    await Api.private.put('/gym-notifications/$notificationId/read');
  }

  // PUT /gym-notifications/read-all
  Future<void> markAllAsRead() async {
    await Api.private.put('/gym-notifications/read-all');
  }

  // DELETE /gym-notifications/{id}
  Future<void> deleteNotification(int notificationId) async {
    await Api.private.delete('/gym-notifications/$notificationId');
  }
}
