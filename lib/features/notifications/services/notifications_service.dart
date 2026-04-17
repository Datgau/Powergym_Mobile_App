import '../../../core/network/api.dart';
import '../../../core/storage/auth_storage.dart';
import '../models/notification_model.dart';

/// ─── Notifications API service ────────────────────────────────────────────────
class NotificationsService {
  final AuthStorage _storage = AuthStorage();

  // GET /notifications/user/{userId}
  Future<List<AppNotification>> getNotifications() async {
    final userId = await _storage.getUserId();
    final res = await Api.private.get('/notifications/user/$userId');
    final raw = (res.data as Map<String, dynamic>)['data'];
    if (raw == null) return [];
    final list = raw is List ? raw : (raw['content'] as List? ?? []);
    return list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  // PUT /notifications/{id}/read
  Future<void> markAsRead(int notificationId) async {
    await Api.private.put('/notifications/$notificationId/read');
  }

  // PUT /notifications/read-all
  Future<void> markAllAsRead() async {
    final userId = await _storage.getUserId();
    await Api.private.put('/notifications/read-all', data: {'userId': userId});
  }

  // DELETE /notifications/{id}
  Future<void> deleteNotification(int notificationId) async {
    await Api.private.delete('/notifications/$notificationId');
  }
}
