import '../../../core/network/api.dart';
import '../models/notification_model.dart';

/// ─── Notifications API service ────────────────────────────────────────────────
class NotificationsService {

  // GET /notifications
  Future<List<AppNotification>> getNotifications() async {
    final res = await Api.private.get('/notifications');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  // GET /notifications/unread-count
  Future<int> getUnreadCount() async {
    try {
      final res = await Api.private.get('/notifications/unread-count');
      final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
      return (data?['count'] as num? ?? 0).toInt();
    } catch (_) {
      return 0;
    }
  }

  // PUT /notifications/{id}/read
  Future<void> markAsRead(int notificationId) async {
    await Api.private.put('/notifications/$notificationId/read');
  }

  // PUT /notifications/read-all
  Future<void> markAllAsRead() async {
    await Api.private.put('/notifications/read-all');
  }

  // DELETE /notifications/{id}
  Future<void> deleteNotification(int notificationId) async {
    await Api.private.delete('/notifications/$notificationId');
  }
}
