import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../../auth/providers/auth_provider.dart';
import '../../notifications/screens/notifications_tab.dart';
import '../models/trainer_models.dart';
import '../services/trainer_service.dart';

class TrainerHomeScreen extends StatefulWidget {
  const TrainerHomeScreen({super.key});

  @override
  State<TrainerHomeScreen> createState() => _TrainerHomeScreenState();
}

class _TrainerHomeScreenState extends State<TrainerHomeScreen> {
  final ValueNotifier<int> _tab = ValueNotifier(0);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _tab,
      builder: (context, idx, _) => Scaffold(
        body: IndexedStack(
          index: idx,
          children: [
            _TrainerDashboard(onTabChange: (i) => _tab.value = i),
            const NotificationsTab(),
            _TrainerProfileTab(onTabChange: (i) => _tab.value = i),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: BottomNavigationBar(
            currentIndex: idx,
            onTap: (i) => _tab.value = i,
            selectedItemColor: AppTheme.primaryBlue,
            unselectedItemColor: AppTheme.textLight,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Tổng quan'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), activeIcon: Icon(Icons.notifications), label: 'Thông báo'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Cá nhân'),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dashboard ─────────────────────────────────────────────────────────────────
class _TrainerDashboard extends StatefulWidget {
  final void Function(int) onTabChange;
  const _TrainerDashboard({required this.onTabChange});

  @override
  State<_TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<_TrainerDashboard> {
  final TrainerService _svc = TrainerService();
  List<TrainerBookingItem> _pending = [];
  List<TrainerBookingItem> _upcoming = [];
  TrainerStats _stats = TrainerStats.empty();
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
      final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
      final results = await Future.wait([
        _svc.getPendingBookings(id),
        _svc.getUpcomingBookings(id),
        _svc.getStatistics(id),
      ]);
      setState(() {
        _pending  = results[0] as List<TrainerBookingItem>;
        _upcoming = results[1] as List<TrainerBookingItem>;
        _stats    = results[2] as TrainerStats;
        _loading  = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = context.watch<AuthProvider>().currentUser?.fullName.split(' ').last ?? 'Trainer';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 190,
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
                              const Text('Xin chào PT 👋', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => widget.onTabChange(2),
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatChip(label: 'Chờ duyệt', value: '${_stats.pendingBookings}'),
                            _VDivider(),
                            _StatChip(label: 'Sắp tới', value: '${_stats.upcomingBookings}'),
                            _VDivider(),
                            _StatChip(label: 'Hoàn thành', value: '${_stats.completedBookings}'),
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
        SliverToBoxAdapter(
          child: _loading
              ? const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
              : _error != null
                  ? _ErrorCard(message: _error!, onRetry: _load)
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _EarningsCard(stats: _stats),
                          const SizedBox(height: 24),
                          _SectionHeader(title: 'Yêu cầu chờ xác nhận', count: _pending.length, countColor: AppTheme.warning),
                          const SizedBox(height: 12),
                          if (_pending.isEmpty)
                            const _EmptyCard(emoji: '', message: 'Không có yêu cầu nào đang chờ')
                          else
                            ..._pending.map((b) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _BookingCard(booking: b, isPending: true))),
                          const SizedBox(height: 24),
                          _SectionHeader(title: 'Lịch tập sắp tới', count: _upcoming.length, countColor: AppTheme.primaryBlue),
                          const SizedBox(height: 12),
                          if (_upcoming.isEmpty)
                            const _EmptyCard(emoji: '📅', message: 'Chưa có lịch tập sắp tới')
                          else
                            ..._upcoming.map((b) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _BookingCard(booking: b, isPending: false))),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }
}

// ── Profile tab (simple) ──────────────────────────────────────────────────────
class _TrainerProfileTab extends StatefulWidget {
  final void Function(int) onTabChange;
  _TrainerProfileTab({required this.onTabChange});

  @override
  State<_TrainerProfileTab> createState() => _TrainerProfileTabState();
}

class _TrainerProfileTabState extends State<_TrainerProfileTab> {
  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: GradientContainer(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(user?.fullName ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('🏋️ Personal Trainer', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _ProfileMenuItem(icon: Icons.person_outline, label: 'Thông tin cá nhân', onTap: () {}),
                _ProfileMenuItem(icon: Icons.schedule_outlined, label: 'Lịch làm việc', onTap: () {}),
                _ProfileMenuItem(icon: Icons.star_outline, label: 'Đánh giá của tôi', onTap: () {}),
                _ProfileMenuItem(icon: Icons.account_balance_wallet_outlined, label: 'Thu nhập', onTap: () {}),
                const SizedBox(height: 8),
                _ProfileMenuItem(
                  icon: Icons.logout_rounded,
                  label: 'Đăng xuất',
                  color: AppTheme.error,
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ProfileMenuItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8EEF5))),
      child: ListTile(
        leading: Icon(icon, color: c, size: 22),
        title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c)),
        trailing: color == null ? const Icon(Icons.chevron_right, color: Color(0xFFC7D2DA), size: 20) : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label, value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      );
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 28, color: Colors.white.withOpacity(0.25));
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
  final TrainerStats stats;
  const _EarningsCard({required this.stats});

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
  Widget build(BuildContext context) => Container(
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
                  Text(_fmt(stats.totalEarnings), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        stats.averageRating > 0 ? stats.averageRating.toStringAsFixed(1) : 'Chưa có',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Text('đánh giá', style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
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
      );
}

class _BookingCard extends StatelessWidget {
  final TrainerBookingItem booking;
  final bool isPending;
  const _BookingCard({required this.booking, required this.isPending});

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
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(gradient: AppTheme.brandGradient, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.person, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.memberName ?? 'Học viên', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  if (booking.serviceName != null) ...[
                    const SizedBox(height: 2),
                    Text(booking.serviceName!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(booking.bookingDate, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule_rounded, size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text('${booking.startTime} – ${booking.endTime}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: _statusColor.withOpacity(0.3))),
              child: Text(booking.statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor)),
            ),
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
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      );
}
