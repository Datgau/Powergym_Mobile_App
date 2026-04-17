import 'package:flutter/foundation.dart';
import '../home/models/trainer_home_models.dart' as home_models;
import '../home/services/trainer_home_service.dart';
import '../models/trainer_models.dart';
import '../services/trainer_websocket_service.dart';

/// Quản lý danh sách thông báo cho trainer.
///
/// Khi khởi động:
///   1. Load các pending bookings hiện có từ REST API → hiển thị ngay (đã đọc)
///   2. Kết nối WebSocket → booking mới đến realtime → unread badge
class TrainerNotificationProvider extends ChangeNotifier {
  final TrainerWebSocketService _ws = TrainerWebSocketService();
  final TrainerHomeService _svc = TrainerHomeService();

  final List<TrainerNotification> _notifications = [];
  int _unreadCount = 0;
  bool _wsConnected = false;
  bool _initialLoaded = false;

  List<TrainerNotification> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get wsConnected => _wsConnected;
  bool get hasUnread => _unreadCount > 0;
  bool get initialLoaded => _initialLoaded;

  // ── Connect / Disconnect ──────────────────────────────────────────────────

  Future<void> connect(String trainerId) async {
    // 1. Load lịch sử pending bookings trước
    await _loadInitialNotifications(trainerId);

    // 2. Kết nối WebSocket
    _ws.onConnected = () {
      _wsConnected = true;
      notifyListeners();
    };

    _ws.onDisconnected = () {
      _wsConnected = false;
      notifyListeners();
    };

    _ws.onNewBooking = (booking) {
      // Tránh duplicate nếu booking đã có trong danh sách
      final exists = _notifications.any(
          (n) => n.booking?.bookingId == booking.bookingId);
      if (!exists) {
        _addNotification(TrainerNotification(
          id: 'ws_${booking.bookingId}_${DateTime.now().millisecondsSinceEpoch}',
          type: TrainerNotificationType.newBooking,
          title: 'Đăng ký mới! 🎉',
          message:
              '${booking.memberName ?? 'Học viên'} vừa đặt lịch tập'
              '${booking.serviceName != null ? ' - ${booking.serviceName}' : ''}',
          booking: booking,
          createdAt: DateTime.now(),
          isRead: false,
        ));
      }
    };

    _ws.onBookingUpdated = (booking) {
      final idx = _notifications.indexWhere(
          (n) => n.booking?.bookingId == booking.bookingId);
      if (idx >= 0) {
        _notifications[idx] = _notifications[idx].copyWith(booking: booking);
        notifyListeners();
      }
    };

    await _ws.connect(trainerId);
  }

  /// Load pending bookings từ REST API và chuyển thành notifications (đã đọc).
  Future<void> _loadInitialNotifications(String trainerId) async {
    try {
      final pending = await _svc.getPendingBookings(trainerId);
      if (pending.isEmpty) {
        _initialLoaded = true;
        notifyListeners();
        return;
      }

      final now = DateTime.now();
      final initial = pending.map((b) {
        // Parse createdAt từ booking nếu có, fallback về now
        return TrainerNotification(
          id: 'init_${b.bookingId}',
          type: TrainerNotificationType.newBooking,
          title: 'Yêu cầu chờ xác nhận',
          message:
              '${b.memberName ?? 'Học viên'} đã đặt lịch tập'
              '${b.serviceName != null ? ' - ${b.serviceName}' : ''}',
          booking: _toNotifBooking(b),
          createdAt: now,
          // Đánh dấu đã đọc vì đây là dữ liệu cũ, không phải mới đến
          isRead: true,
        );
      }).toList();

      _notifications.addAll(initial);
      // Không tăng _unreadCount vì đây là dữ liệu cũ
      _initialLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[Notif] Failed to load initial notifications: $e');
      _initialLoaded = true;
      notifyListeners();
    }
  }

  /// Refresh lại danh sách từ REST (dùng khi pull-to-refresh)
  Future<void> refresh(String trainerId) async {
    // Xóa các notification cũ từ REST (giữ lại WebSocket realtime)
    _notifications.removeWhere((n) => n.id.startsWith('init_'));
    await _loadInitialNotifications(trainerId);
  }

  void disconnect() {
    _ws.disconnect();
    _wsConnected = false;
    notifyListeners();
  }

  // ── Notification management ───────────────────────────────────────────────

  void _addNotification(TrainerNotification notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) _unreadCount++;
    notifyListeners();
  }

  void markAllRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _unreadCount = 0;
    notifyListeners();
  }

  void markRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      _unreadCount = (_unreadCount - 1).clamp(0, _notifications.length);
      notifyListeners();
    }
  }

  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  // ── Helper: convert home_models.TrainerBookingItem → trainer_models.TrainerBookingItem ──

  TrainerBookingItem _toNotifBooking(home_models.TrainerBookingItem b) {
    return TrainerBookingItem(
      id: b.id,
      bookingId: b.bookingId,
      bookingDate: b.bookingDate,
      startTime: b.startTime,
      endTime: b.endTime,
      status: b.status,
      memberName: b.memberName,
      memberAvatar: b.memberAvatar,
      serviceName: b.serviceName,
      notes: b.notes,
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

enum TrainerNotificationType { newBooking, bookingUpdated, system }

class TrainerNotification {
  final String id;
  final TrainerNotificationType type;
  final String title;
  final String message;
  final TrainerBookingItem? booking;
  final DateTime createdAt;
  final bool isRead;

  const TrainerNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.booking,
    required this.createdAt,
    this.isRead = false,
  });

  TrainerNotification copyWith({
    bool? isRead,
    TrainerBookingItem? booking,
  }) =>
      TrainerNotification(
        id: id,
        type: type,
        title: title,
        message: message,
        booking: booking ?? this.booking,
        createdAt: createdAt,
        isRead: isRead ?? this.isRead,
      );

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }
}
