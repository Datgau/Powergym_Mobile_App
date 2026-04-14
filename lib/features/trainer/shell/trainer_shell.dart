import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import '../home/providers/trainer_home_provider.dart';
import '../home/screens/trainer_home_tab.dart';
import '../clients/providers/clients_provider.dart';
import '../clients/screens/clients_tab.dart';
import '../schedule/providers/schedule_provider.dart';
import '../schedule/screens/schedule_tab.dart';
import '../earnings/providers/earnings_provider.dart';
import '../earnings/screens/earnings_tab.dart';
import '../profile/screens/trainer_profile_tab.dart';

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
        ChangeNotifierProvider(create: (_) => ClientsProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => EarningsProvider()),
      ],
      child: ValueListenableBuilder<int>(
        valueListenable: _tab,
        builder: (context, idx, _) => Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          body: IndexedStack(
            index: idx,
            children: [
              TrainerHomeTab(onTabChange: (i) => _tab.value = i),
              const ClientsTab(),
              const ScheduleTab(),
              const EarningsTab(),
              const TrainerProfileTab(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
            ),
            child: SafeArea(
              top: false,
              child: BottomNavigationBar(
                currentIndex: idx,
                onTap: (i) => _tab.value = i,
                selectedItemColor: AppTheme.primaryBlue,
                unselectedItemColor: AppTheme.textLight,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: 'Trang chủ',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline),
                    activeIcon: Icon(Icons.people_rounded),
                    label: 'Học viên',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_month_outlined),
                    activeIcon: Icon(Icons.calendar_month_rounded),
                    label: 'Lịch tập',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    activeIcon: Icon(Icons.account_balance_wallet_rounded),
                    label: 'Thu nhập',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person_rounded),
                    label: 'Cá nhân',
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
