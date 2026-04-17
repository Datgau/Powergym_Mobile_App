import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/trainer_models.dart';
import '../providers/trainer_notification_provider.dart';

/// Màn hình thông báo realtime dành cho trainer.
/// Hiển thị các booking mới và cập nhật trạng thái qua WebSocket.
class TrainerNotificationsScreen extends StatelessWidget {
  const TrainerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainerNotificationProvider>(
      builder: (context, provider, _) {
        final trainerId =
            context.read<AuthProvider>().currentUser?.id.toString() ?? '';

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: RefreshIndicator(
            onRefresh: () => provider.refresh(trainerId),
            child: CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: GradientContainer(
                    child: SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(24, 20, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Thông báo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const Spacer(),
                                // WebSocket status indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: provider.wsConnected
                                              ? Colors.greenAccent
                                              : Colors.orange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        provider.wsConnected
                                            ? 'Realtime'
                                            : 'Đang kết nối...',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (provider.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${provider.unreadCount} thông báo mới',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (provider.notifications.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear_all,
                          color: Colors.white),
                      tooltip: 'Xóa tất cả',
                      onPressed: () => _confirmClear(context, provider),
                    ),
                ],
              ),

              // ── Body ─────────────────────────────────────────────────
              if (!provider.initialLoaded)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (provider.notifications.isEmpty)
                SliverFillRemaining(
                  child: _EmptyState(wsConnected: provider.wsConnected),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notif = provider.notifications[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TrainerNotifCard(
                            notification: notif,
                            onTap: () => provider.markRead(notif.id),
                          ),
                        );
                      },
                      childCount: provider.notifications.length,
                    ),
                  ),
                ),
            ],
          ),
          ), // RefreshIndicator
        );
      },
    );
  }

  void _confirmClear(
      BuildContext context, TrainerNotificationProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa thông báo'),
        content: const Text('Xóa tất cả thông báo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool wsConnected;
  const _EmptyState({required this.wsConnected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                size: 40, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có thông báo',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            wsConnected
                ? 'Bạn sẽ nhận thông báo ngay khi có đăng ký mới'
                : 'Đang kết nối realtime...',
            style: const TextStyle(
                fontSize: 13, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (!wsConnected) ...[
            const SizedBox(height: 12),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Notification card ─────────────────────────────────────────────────────────
class _TrainerNotifCard extends StatelessWidget {
  final TrainerNotification notification;
  final VoidCallback onTap;
  const _TrainerNotifCard(
      {required this.notification, required this.onTap});

  Color get _iconBg {
    switch (notification.type) {
      case TrainerNotificationType.newBooking:
        return const Color(0xFFE8F5E9);
      case TrainerNotificationType.bookingUpdated:
        return const Color(0xFFE3F2FD);
      case TrainerNotificationType.system:
        return const Color(0xFFFFF8E1);
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case TrainerNotificationType.newBooking:
        return AppTheme.success;
      case TrainerNotificationType.bookingUpdated:
        return AppTheme.primaryBlue;
      case TrainerNotificationType.system:
        return AppTheme.warning;
    }
  }

  IconData get _icon {
    switch (notification.type) {
      case TrainerNotificationType.newBooking:
        return Icons.person_add_rounded;
      case TrainerNotificationType.bookingUpdated:
        return Icons.update_rounded;
      case TrainerNotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRead
                ? Colors.grey[200]!
                : AppTheme.primaryBlue.withOpacity(0.2),
            width: isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isRead
                  ? Colors.black.withOpacity(0.03)
                  : AppTheme.primaryBlue.withOpacity(0.08),
              blurRadius: isRead ? 8 : 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _iconColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(_icon, color: _iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                        fontWeight: isRead
                            ? FontWeight.w400
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Booking detail chip (nếu có)
                    if (notification.booking != null) ...[
                      _BookingChip(booking: notification.booking!),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 13, color: AppTheme.textLight),
                        const SizedBox(width: 4),
                        Text(
                          notification.timeAgo,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingChip extends StatelessWidget {
  final TrainerBookingItem booking;
  const _BookingChip({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 12, color: AppTheme.textSecondary),
          const SizedBox(width: 5),
          Text(
            '${booking.bookingDate}  ${booking.startTime}–${booking.endTime}',
            style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
