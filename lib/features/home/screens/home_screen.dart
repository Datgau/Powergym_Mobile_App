import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import '../providers/home_provider.dart';
import 'home_tab.dart';
import '../../bookings/screens/bookings_tab.dart';
import '../../packages/screens/packages_tab.dart';
import '../../notifications/screens/notifications_tab.dart';
import '../../profile/screens/profile_tab.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final ValueNotifier<int> _tabNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _tabNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _tabNotifier,
      builder: (context, selectedIndex, _) {
        return Scaffold(
          body: IndexedStack(
            index: selectedIndex,
            children: [
              HomeTab(onTabChange: (i) => _tabNotifier.value = i),
              const BookingsTab(),
              const PackagesTab(),
              const NotificationsTab(),
              const ProfileTab(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: (index) => _tabNotifier.value = index,
              selectedItemColor: AppTheme.primaryBlue,
              unselectedItemColor: AppTheme.textLight,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: 'Lịch tập',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center_outlined),
                  activeIcon: Icon(Icons.fitness_center),
                  label: 'Gói tập',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_none_outlined),
                  activeIcon: Icon(Icons.notifications),
                  label: 'Thông báo',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Cá nhân',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
