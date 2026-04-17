/// ─── Notification models ──────────────────────────────────────────────────────

class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id:        json['id'] as int,
        title:     json['title'] as String? ?? '',
        message:   json['message'] as String? ?? '',
        type:      json['type'] as String? ?? '',
        isRead:    json['isRead'] as bool? ?? false,
        createdAt: json['createdAt'] as String? ?? '',
      );
}
