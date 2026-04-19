import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../widgets/gradient_container.dart';
import '../services/packages_service.dart';
import 'packages_tab.dart';
import 'services_tab.dart';

/// Màn hình "Gói tập" với 2 tab: Dịch vụ | Gói tập
class PackagesWithTabsScreen extends StatefulWidget {
  const PackagesWithTabsScreen({super.key});

  @override
  State<PackagesWithTabsScreen> createState() => _PackagesWithTabsScreenState();
}

class _PackagesWithTabsScreenState extends State<PackagesWithTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PackagesService _packagesService = PackagesService();

  List<Map<String, dynamic>> _userPackages = [];
  bool _loadingUserPackages = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserPackages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPackages() async {
    try {
      final list = await _packagesService.getUserPackages();
      if (mounted) setState(() => _userPackages = list);
    } catch (_) {
      // user chưa có gói — bỏ qua
    } finally {
      if (mounted) setState(() => _loadingUserPackages = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Gradient Header ──────────────────────────────────────────────
          GradientContainer(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gói tập & Dịch vụ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        _ActiveBadge(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Gói đang active
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: _loadingUserPackages
                        ? const Text(
                            'Đang tải...',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          )
                        : _ActivePackageSummary(packages: _userPackages),
                  ),

                  const SizedBox(height: 10),

                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 2,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    tabs: const [
                      Tab(text: 'Dịch vụ', height: 36),
                      Tab(text: 'Gói tập', height: 36),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tab Content ──────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const ServicesTab(),
                PackagesTab(onPaymentSuccess: _loadUserPackages),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge "Đang hoạt động" ───────────────────────────────────────────────────
class _ActiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF4ADE80),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Đang hoạt động',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tóm tắt gói active ───────────────────────────────────────────────────────
class _ActivePackageSummary extends StatelessWidget {
  final List<Map<String, dynamic>> packages;
  const _ActivePackageSummary({required this.packages});

  @override
  Widget build(BuildContext context) {
    final active = packages.where((p) {
      final status = (p['status'] as String? ?? '').toUpperCase();
      return status == 'ACTIVE';
    }).toList();

    if (active.isEmpty) {
      return const Text(
        'Bạn chưa có gói tập nào đang hoạt động.',
        style: TextStyle(color: Colors.white70, fontSize: 13),
      );
    }

    final pkg = active.first;
    final name = pkg['packageName'] as String? ?? pkg['name'] as String? ?? 'Gói tập';
    final endDate = pkg['endDate'] as String? ?? '';
    final daysLeft = pkg['daysLeft'] as int? ?? 0;

    return Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 15),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            endDate.isNotEmpty ? 'HH: $endDate • Còn $daysLeft ngày' : 'Còn $daysLeft ngày',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
