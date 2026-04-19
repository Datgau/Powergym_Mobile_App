/// ─── Notification models ──────────────────────────────────────────────────────

class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;
  final int? relatedId;
  final String? actorName;
  final String? actorAvatar;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.relatedId,
    this.actorName,
    this.actorAvatar,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id:          (json['id'] as num).toInt(),
        title:       json['title'] as String? ?? '',
        message:     json['content'] as String? ?? json['message'] as String? ?? '',
        type:        json['type'] as String? ?? '',
        isRead:      json['isRead'] as bool? ?? false,
        createdAt:   json['createdAt'] as String? ?? '',
        relatedId:   json['relatedId'] != null ? (json['relatedId'] as num).toInt() : null,
        actorName:   json['actorFullName'] as String?,
        actorAvatar: json['actorAvatar'] as String?,
      );
}
