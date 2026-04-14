import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/trainer_home_models.dart';
import '../providers/trainer_home_provider.dart';

class TrainerHomeTab extends StatefulWidget {
  final void Function(int) onTabChange;
  const TrainerHomeTab({super.key, required this.onTabChange});

  @override
  State<TrainerHomeTab> createState() => _TrainerHomeTabState();
}

class _TrainerHomeTabState extends State<TrainerHomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
      context.read<TrainerHomeProvider>().loadAll(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthProvider>().currentUser?.fullName.split(' ').last ?? 'Trainer';
    final provider = context.watch<TrainerHomeProvider>();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Header ──────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          elevation: 0,
          backgroundColor: AppTheme.primaryBlue,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: GradientContainer(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Xin chào PT 👋',
                                  style: TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => widget.onTabChange(4),
                            child: Container(
                              width: 52, height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 28),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Stats strip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatChip(label: 'Học viên', value: '${provider.stats.totalClients}'),
                            _VDivider(),
                            _StatChip(label: 'Chờ duyệt', value: '${provider.stats.pendingBookings}'),
                            _VDivider(),
                            _StatChip(label: 'Sắp tới', value: '${provider.stats.upcomingBookings}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Body ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: provider.isLoading
              ? const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
              : provider.status == TrainerHomeStatus.error
                  ? _ErrorCard(message: provider.error, onRetry: () {
                      final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
                      context.read<TrainerHomeProvider>().loadAll(id);
                    })
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Earnings card
                          _EarningsCard(
                            earnings: provider.stats.totalEarnings,
                            rating: provider.stats.averageRating,
                            onTap: () => widget.onTabChange(3),
                          ),
                          const SizedBox(height: 24),

                          // Quick actions
                          Row(
                            children: [
                              Expanded(child: _QuickAction(icon: Icons.people_rounded, label: 'Học viên', color: const Color(0xFF7C3AED), onTap: () => widget.onTabChange(1))),
                              const SizedBox(width: 12),
                              Expanded(child: _QuickAction(icon: Icons.calendar_month_rounded, label: 'Lịch tập', color: AppTheme.primaryBlue, onTap: () => widget.onTabChange(2))),
                              const SizedBox(width: 12),
                              Expanded(child: _QuickAction(icon: Icons.account_balance_wallet_rounded, label: 'Thu nhập', color: const Color(0xFF059669), onTap: () => widget.onTabChange(3))),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Pending requests
                          _SectionHeader(
                              title: 'Yêu cầu chờ xác nhận',
                              count: provider.pendingBookings.length,
                              countColor: AppTheme.warning),
                          const SizedBox(height: 12),
                          if (provider.pendingBookings.isEmpty)
                            const _EmptyCard(emoji: '✅', message: 'Không có yêu cầu nào đang chờ')
                          else
                            ...provider.pendingBookings.map((b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _BookingCard(
                                    booking: b,
                                    isPending: true,
                                    onAccept: () {
                                      final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
                                      context.read<TrainerHomeProvider>().acceptBooking(id, b.bookingId);
                                    },
                                    onReject: () => _showRejectDialog(context, b),
                                  ),
                                )),
                          const SizedBox(height: 24),

                          // Upcoming
                          _SectionHeader(
                              title: 'Lịch tập sắp tới',
                              count: provider.upcomingBookings.length,
                              countColor: AppTheme.primaryBlue),
                          const SizedBox(height: 12),
                          if (provider.upcomingBookings.isEmpty)
                            const _EmptyCard(emoji: '📅', message: 'Chưa có lịch tập sắp tới')
                          else
                            ...provider.upcomingBookings.map((b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _BookingCard(booking: b, isPending: false),
                                )),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  void _showRejectDialog(BuildContext context, TrainerBookingItem booking) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Từ chối lịch hẹn'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Lý do từ chối...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
              context.read<TrainerHomeProvider>().rejectBooking(id, booking.bookingId, ctrl.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
        ],
      );
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: Colors.white.withOpacity(0.25));
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color countColor;
  const _SectionHeader({required this.title, required this.count, required this.countColor});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.3)),
          const SizedBox(width: 8),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: countColor, borderRadius: BorderRadius.circular(10)),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
        ],
      );
}

class _EarningsCard extends StatelessWidget {
  final double earnings;
  final double rating;
  final VoidCallback onTap;
  const _EarningsCard({required this.earnings, required this.rating, required this.onTap});

  String _fmt(double v) {
    final parts = v.toInt().toString().split('').reversed.toList();
    final r = <String>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && i % 3 == 0) r.add('.');
      r.add(parts[i]);
    }
    return '${r.reversed.join()}đ';
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thu nhập tháng này', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(_fmt(earnings), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 4),
                      Text(rating > 0 ? rating.toStringAsFixed(1) : 'Chưa có',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Text('đánh giá', style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ]),
                  ],
                ),
              ),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 4))]),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
        ),
      );
}

class _BookingCard extends StatelessWidget {
  final TrainerBookingItem booking;
  final bool isPending;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  const _BookingCard({required this.booking, required this.isPending, this.onAccept, this.onReject});

  Color get _statusColor {
    switch (booking.status) {
      case 'CONFIRMED': return AppTheme.success;
      case 'PENDING':   return AppTheme.warning;
      case 'CANCELLED': return AppTheme.error;
      case 'COMPLETED': return AppTheme.primaryBlue;
      default:          return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isPending ? AppTheme.warning.withOpacity(0.3) : const Color(0xFFE8EEF5), width: isPending ? 1.5 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(13)),
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.memberName ?? 'Học viên',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                      if (booking.serviceName != null)
                        Text(booking.serviceName!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(booking.statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12, runSpacing: 4,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(booking.bookingDate, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.schedule_rounded, size: 12, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text('${booking.startTime} – ${booking.endTime}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ]),
              ],
            ),
            if (isPending && onAccept != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.error, side: BorderSide(color: AppTheme.error.withOpacity(0.5))),
                      child: const Text('Từ chối', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white, elevation: 0),
                      child: const Text('Xác nhận', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
}

class _EmptyCard extends StatelessWidget {
  final String emoji, message;
  const _EmptyCard({required this.emoji, required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8EEF5))),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(message, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ]),
      );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ]),
      );
}
