import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/services/notifications_service.dart';
import '../../notifications/services/user_websocket_service.dart';

/// Trainer notifications screen - displays gym notifications from database + real-time WebSocket
class TrainerNotificationsScreen extends StatefulWidget {
  const TrainerNotificationsScreen({super.key});

  @override
  State<TrainerNotificationsScreen> createState() => _TrainerNotificationsScreenState();
}

class _TrainerNotificationsScreenState extends State<TrainerNotificationsScreen> {
  final NotificationsService _svc = NotificationsService();
  final UserWebSocketService _ws = UserWebSocketService();

  List<AppNotification> _notifications = [];
  bool _loading = true;
  String? _error;
  bool _wsConnected = false;

  @override
  void initState() {
    super.initState();
    _load();
    _connectWs();
  }

  @override
  void dispose() {
    _ws.disconnect();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _svc.getNotifications();
      if (mounted) setState(() => _notifications = list);
    } catch (e) {
      if (mounted) {
        final msg = e.toString();
        if (!msg.contains('401') && !msg.contains('403')) {
          setState(() => _error = 'Could not load notifications');
        } else {
          setState(() => _notifications = []);
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _connectWs() {
    final userId = context.read<AuthProvider>().currentUser?.id.toString();
    if (userId == null) return;

    _ws.onConnected = () {
      if (mounted) setState(() => _wsConnected = true);
    };
    _ws.onDisconnected = () {
      if (mounted) setState(() => _wsConnected = false);
    };
    _ws.onNotification = (payload) {
      if (!mounted) return;
      final n = AppNotification.fromJson(payload);
      setState(() {
        _notifications = [n, ..._notifications];
      });
      _showSnackBar(n);
    };

    _ws.connect(userId);
  }

  void _showSnackBar(AppNotification n) {
    final (_, color, _) = _typeConfig(n.type);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(_typeIcon(n.type), color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(n.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13)),
                  if (n.message.isNotEmpty)
                    Text(n.message,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _markAllRead() async {
    await _svc.markAllAsRead();
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  Future<void> _markRead(AppNotification n) async {
    if (n.isRead) return;
    await _svc.markAsRead(n.id);
    setState(() {
      final idx = _notifications.indexWhere((x) => x.id == n.id);
      if (idx != -1) _notifications[idx] = n.copyWith(isRead: true);
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
            expandedHeight: 130,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: GradientContainer(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Notifications',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800)),
                            Row(
                              children: [
                                // WebSocket status dot
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _wsConnected
                                        ? const Color(0xFF10B981)
                                        : Colors.white38,
                                  ),
                                ),
                                if (_unreadCount > 0)
                                  TextButton(
                                    onPressed: _markAllRead,
                                    child: const Text('Mark all read',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12)),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.refresh_rounded,
                                      color: Colors.white70, size: 20),
                                  onPressed: _load,
                                ),
                              ],
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
                            child: Text('$_unreadCount new notification${_unreadCount > 1 ? 's' : ''}',
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
                    const Text('Could not load notifications',
                        style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _load, child: const Text('Retry')),
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
                    Text('No notifications yet',
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


// ── Type config helpers ────────────────────────────────────────────────────
IconData _typeIcon(String type) {
  switch (type) {
    case 'NEW_BOOKING_REQUEST': return Icons.person_add_rounded;
    case 'BOOKING_CONFIRMED': return Icons.check_circle_rounded;
    case 'BOOKING_REJECTED': return Icons.cancel_rounded;
    case 'BOOKING_CANCELLED': return Icons.event_busy_rounded;
    case 'SERVICE_REGISTERED': return Icons.fitness_center_rounded;
    case 'MEMBERSHIP_ACTIVATED': return Icons.card_membership_rounded;
    case 'MEMBERSHIP_EXPIRING': return Icons.warning_amber_rounded;
    case 'MEMBERSHIP_EXPIRED': return Icons.timer_off_rounded;
    case 'PAYMENT_SUCCESS': return Icons.payment_rounded;
    case 'TRAINER_ASSIGNED': return Icons.person_rounded;
    default: return Icons.notifications_rounded;
  }
}

(Color, Color, Color) _typeConfig(String type) {
  switch (type) {
    case 'NEW_BOOKING_REQUEST':
      return (Icons.person_add_rounded as dynamic,
          const Color(0xFF7C3AED), const Color(0xFFF3E8FF));
    case 'SERVICE_REGISTERED':
      return (Icons.fitness_center_rounded as dynamic,
          const Color(0xFF059669), const Color(0xFFDCFCE7));
    case 'BOOKING_CONFIRMED':
      return (Icons.check_circle_rounded as dynamic,
          const Color(0xFF059669), const Color(0xFFDCFCE7));
    case 'BOOKING_REJECTED':
      return (Icons.cancel_rounded as dynamic,
          const Color(0xFFDC2626), const Color(0xFFFFEBEE));
    case 'BOOKING_CANCELLED':
      return (Icons.event_busy_rounded as dynamic,
          const Color(0xFFD97706), const Color(0xFFFFF8E1));
    case 'MEMBERSHIP_ACTIVATED':
      return (Icons.card_membership_rounded as dynamic,
          const Color(0xFF0284C7), const Color(0xFFE0F2FE));
    case 'MEMBERSHIP_EXPIRING':
      return (Icons.warning_amber_rounded as dynamic,
          const Color(0xFFD97706), const Color(0xFFFFF8E1));
    case 'MEMBERSHIP_EXPIRED':
      return (Icons.timer_off_rounded as dynamic,
          const Color(0xFFDC2626), const Color(0xFFFFEBEE));
    case 'PAYMENT_SUCCESS':
      return (Icons.payment_rounded as dynamic,
          const Color(0xFF059669), const Color(0xFFDCFCE7));
    case 'TRAINER_ASSIGNED':
      return (Icons.person_rounded as dynamic,
          const Color(0xFF7C3AED), const Color(0xFFF3E8FF));
    default:
      return (Icons.notifications_rounded as dynamic,
          AppTheme.primaryBlue, const Color(0xFFE0F2FE));
  }
}

// ── Notification Card ─────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  Color get _iconColor {
    switch (notification.type) {
      case 'NEW_BOOKING_REQUEST': return const Color(0xFF7C3AED);
      case 'SERVICE_REGISTERED': return const Color(0xFF059669);
      case 'BOOKING_CONFIRMED': return const Color(0xFF059669);
      case 'BOOKING_REJECTED': return const Color(0xFFDC2626);
      case 'BOOKING_CANCELLED': return const Color(0xFFD97706);
      case 'MEMBERSHIP_ACTIVATED': return const Color(0xFF0284C7);
      case 'MEMBERSHIP_EXPIRING': return const Color(0xFFD97706);
      case 'MEMBERSHIP_EXPIRED': return const Color(0xFFDC2626);
      case 'PAYMENT_SUCCESS': return const Color(0xFF059669);
      case 'TRAINER_ASSIGNED': return const Color(0xFF7C3AED);
      default: return AppTheme.primaryBlue;
    }
  }

  Color get _bgColor {
    switch (notification.type) {
      case 'NEW_BOOKING_REQUEST': return const Color(0xFFF3E8FF);
      case 'SERVICE_REGISTERED': return const Color(0xFFDCFCE7);
      case 'BOOKING_CONFIRMED': return const Color(0xFFDCFCE7);
      case 'BOOKING_REJECTED': return const Color(0xFFFFEBEE);
      case 'BOOKING_CANCELLED': return const Color(0xFFFFF8E1);
      case 'MEMBERSHIP_ACTIVATED': return const Color(0xFFE0F2FE);
      case 'MEMBERSHIP_EXPIRING': return const Color(0xFFFFF8E1);
      case 'MEMBERSHIP_EXPIRED': return const Color(0xFFFFEBEE);
      case 'PAYMENT_SUCCESS': return const Color(0xFFDCFCE7);
      case 'TRAINER_ASSIGNED': return const Color(0xFFF3E8FF);
      default: return const Color(0xFFE0F2FE);
    }
  }

  String _formatTime() {
    try {
      final dt = DateTime.parse(notification.createdAt);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return notification.createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  color: _bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(_typeIcon(notification.type),
                  color: _iconColor, size: 22),
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
                            fontWeight:
                                isRead ? FontWeight.w600 : FontWeight.w800,
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
