import 'package:flutter/material.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../models/notification_model.dart';
import '../services/notifications_service.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final NotificationsService _svc = NotificationsService();
  List<AppNotification> _notifications = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _svc.getNotifications();
      if (mounted) setState(() => _notifications = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    await _svc.markAllAsRead();
    setState(() {
      _notifications = _notifications.map((n) => AppNotification(
        id: n.id, title: n.title, message: n.message,
        type: n.type, isRead: true, createdAt: n.createdAt,
        relatedId: n.relatedId, actorName: n.actorName, actorAvatar: n.actorAvatar,
      )).toList();
    });
  }

  Future<void> _markRead(AppNotification n) async {
    if (n.isRead) return;
    await _svc.markAsRead(n.id);
    setState(() {
      final idx = _notifications.indexWhere((x) => x.id == n.id);
      if (idx != -1) {
        _notifications[idx] = AppNotification(
          id: n.id, title: n.title, message: n.message,
          type: n.type, isRead: true, createdAt: n.createdAt,
          relatedId: n.relatedId, actorName: n.actorName, actorAvatar: n.actorAvatar,
        );
      }
    });
  }

  Future<void> _delete(AppNotification n) async {
    await _svc.deleteNotification(n.id);
    setState(() => _notifications.removeWhere((x) => x.id == n.id));
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: GradientContainer(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Thông báo',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                            if (_unreadCount > 0)
                              TextButton(
                                onPressed: _markAllRead,
                                child: const Text('Đọc tất cả',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 12)),
                              ),
                          ],
                        ),
                        if (_unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text('$_unreadCount thông báo mới',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.error, size: 48),
                    const SizedBox(height: 12),
                    const Text('Không thể tải thông báo',
                        style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _load, child: const Text('Thử lại')),
                  ],
                ),
              ),
            )
          else if (_notifications.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🔔', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text('Chưa có thông báo nào',
                        style: TextStyle(
                            fontSize: 15, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final n = _notifications[i];
                    return Dismissible(
                      key: Key('notif_${n.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white),
                      ),
                      onDismissed: (_) => _delete(n),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _NotificationCard(
                          notification: n,
                          onTap: () => _markRead(n),
                        ),
                      ),
                    );
                  },
                  childCount: _notifications.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Notification Card ─────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  static const _typeConfig = {
    'BOOKING_CONFIRMED':   (Icons.check_circle_rounded,   Color(0xFF059669), Color(0xFFDCFCE7)),
    'BOOKING_REJECTED':    (Icons.cancel_rounded,          Color(0xFFDC2626), Color(0xFFFFEBEE)),
    'BOOKING_CANCELLED':   (Icons.event_busy_rounded,      Color(0xFFD97706), Color(0xFFFFF8E1)),
    'BOOKING_COMPLETED':   (Icons.emoji_events_rounded,    Color(0xFF7C3AED), Color(0xFFF3E8FF)),
    'BOOKING_REMINDER':    (Icons.alarm_rounded,           Color(0xFF0284C7), Color(0xFFE0F2FE)),
    'PAYMENT_SUCCESS':     (Icons.payment_rounded,         Color(0xFF059669), Color(0xFFDCFCE7)),
    'PAYMENT_FAILED':      (Icons.payment_rounded,         Color(0xFFDC2626), Color(0xFFFFEBEE)),
    'MEMBERSHIP_ACTIVATED':(Icons.card_membership_rounded, Color(0xFF0284C7), Color(0xFFE0F2FE)),
    'MEMBERSHIP_EXPIRING': (Icons.warning_amber_rounded,   Color(0xFFD97706), Color(0xFFFFF8E1)),
    'MEMBERSHIP_EXPIRED':  (Icons.timer_off_rounded,       Color(0xFFDC2626), Color(0xFFFFEBEE)),
    'SERVICE_REGISTERED':  (Icons.fitness_center_rounded,  Color(0xFF059669), Color(0xFFDCFCE7)),
    'TRAINER_ASSIGNED':    (Icons.person_rounded,          Color(0xFF7C3AED), Color(0xFFF3E8FF)),
    'SYSTEM':              (Icons.info_rounded,            Color(0xFF0284C7), Color(0xFFE0F2FE)),
  };

  (IconData, Color, Color) get _config {
    final cfg = _typeConfig[notification.type];
    if (cfg != null) return cfg;
    // Social fallback
    return (Icons.notifications_rounded, AppTheme.primaryBlue, const Color(0xFFE0F2FE));
  }

  String _formatTime() {
    try {
      final dt = DateTime.parse(notification.createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Vừa xong';
      if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
      if (diff.inHours < 24) return '${diff.inHours} giờ trước';
      if (diff.inDays < 7) return '${diff.inDays} ngày trước';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return notification.createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor, bgColor) = _config;
    final isRead = notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead
                ? const Color(0xFFE2E8F0)
                : AppTheme.primaryBlue.withOpacity(0.2),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isRead
                  ? Colors.black.withOpacity(0.03)
                  : AppTheme.primaryBlue.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title.isNotEmpty
                              ? notification.title
                              : notification.type,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  if (notification.message.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                        fontWeight:
                            isRead ? FontWeight.w400 : FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 11, color: AppTheme.textLight),
                      const SizedBox(width: 3),
                      Text(_formatTime(),
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textLight)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
