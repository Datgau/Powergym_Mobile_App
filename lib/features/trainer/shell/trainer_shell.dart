import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import '../home/providers/trainer_home_provider.dart';
import '../home/screens/trainer_home_tab.dart';
import '../schedule/providers/schedule_provider.dart';
import '../schedule/screens/schedule_tab.dart';
import '../earnings/providers/earnings_provider.dart';
import '../earnings/screens/earnings_tab.dart';
import '../profile/screens/trainer_profile_tab.dart';
import '../providers/trainer_notification_provider.dart';
import '../screens/trainer_notifications_screen.dart';
import '../../auth/providers/auth_provider.dart';

/// Entry point cho trainer sau khi đăng nhập.
/// Cung cấp tất cả providers cần thiết và bottom navigation 5 tab.
class TrainerShell extends StatefulWidget {
  const TrainerShell({super.key});

  @override
  State<TrainerShell> createState() => _TrainerShellState();
}

class _TrainerShellState extends State<TrainerShell> {
  final ValueNotifier<int> _tab = ValueNotifier(0);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrainerHomeProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => EarningsProvider()),
      ],
      child: _TrainerShellBody(tab: _tab),
    );
  }
}

class _TrainerShellBody extends StatefulWidget {
  final ValueNotifier<int> tab;
  const _TrainerShellBody({required this.tab});

  @override
  State<_TrainerShellBody> createState() => _TrainerShellBodyState();
}

class _TrainerShellBodyState extends State<_TrainerShellBody> {
  bool _wsInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_wsInitialized) {
      _wsInitialized = true;
      final trainerId =
          context.read<AuthProvider>().currentUser?.id.toString();
      if (trainerId != null) {
        final notifProvider = context.read<TrainerNotificationProvider>();
        notifProvider.connect(trainerId);

        // Khi có booking mới → refresh home tab
        notifProvider.addListener(() {
          if (!mounted) return;
          final homeProvider = context.read<TrainerHomeProvider>();
          homeProvider.loadAll(trainerId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: widget.tab,
      builder: (context, idx, _) => Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: IndexedStack(
          index: idx,
          children: [
            TrainerHomeTab(onTabChange: (i) => widget.tab.value = i),
            const ScheduleTab(),
            const EarningsTab(),
            const TrainerNotificationsScreen(),
            const TrainerProfileTab(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4))
            ],
          ),
          child: SafeArea(
            top: false,
            child: Consumer<TrainerNotificationProvider>(
              builder: (context, notifProvider, _) => BottomNavigationBar(
                currentIndex: idx,
                onTap: (i) {
                  widget.tab.value = i;
                  // Đánh dấu đã đọc khi mở tab thông báo (index 3)
                  if (i == 3) notifProvider.markAllRead();
                },
                selectedItemColor: AppTheme.primaryBlue,
                unselectedItemColor: AppTheme.textLight,
                selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 11),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_outlined),
                    activeIcon: Icon(Icons.calendar_month_rounded),
                    label: 'Schedule',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    activeIcon: Icon(Icons.account_balance_wallet_rounded),
                    label: 'Earnings',
                  ),
                  // Tab thông báo với badge
                  BottomNavigationBarItem(
                    icon: _NotifBadge(
                        count: notifProvider.unreadCount, active: false),
                    activeIcon: _NotifBadge(
                        count: notifProvider.unreadCount, active: true),
                    label: 'Notifications',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge icon cho tab thông báo
class _NotifBadge extends StatelessWidget {
  final int count;
  final bool active;
  const _NotifBadge({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(active
            ? Icons.notifications_rounded
            : Icons.notifications_none_outlined),
        if (count > 0)
          Positioned(
            top: -4,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              constraints:
                  const BoxConstraints(minWidth: 16, minHeight: 16),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
