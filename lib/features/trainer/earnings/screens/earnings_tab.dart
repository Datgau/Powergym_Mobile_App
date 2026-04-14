import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/earnings_model.dart';
import '../providers/earnings_provider.dart';

class EarningsTab extends StatefulWidget {
  const EarningsTab({super.key});

  @override
  State<EarningsTab> createState() => _EarningsTabState();
}

class _EarningsTabState extends State<EarningsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
      context.read<EarningsProvider>().load(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EarningsProvider>();

    return CustomScrollView(
      slivers: [
        // ── Header ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: GradientContainer(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thu nhập', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    if (!provider.isLoading) ...[
                      Text(
                        _fmt(provider.earnings.totalSalary),
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cập nhật: ${_fmtDate(provider.earnings.calculatedAt)}',
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Body ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: provider.isLoading
              ? const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
              : provider.status == EarningsStatus.error
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
                        const SizedBox(height: 8),
                        Text(provider.error, style: const TextStyle(color: AppTheme.textSecondary)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
                            context.read<EarningsProvider>().load(id);
                          },
                          child: const Text('Thử lại'),
                        ),
                      ]),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Chi tiết theo dịch vụ',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                          const SizedBox(height: 12),
                          if (provider.earnings.serviceBreakdown.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE8EEF5))),
                              child: const Row(children: [
                                Text('💰', style: TextStyle(fontSize: 24)),
                                SizedBox(width: 12),
                                Text('Chưa có dữ liệu thu nhập', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                              ]),
                            )
                          else
                            ...provider.earnings.serviceBreakdown.map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ServiceEarningCard(earning: s),
                              ),
                            ),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    final parts = v.toInt().toString().split('').reversed.toList();
    final r = <String>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && i % 3 == 0) r.add('.');
      r.add(parts[i]);
    }
    return '${r.reversed.join()}đ';
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _ServiceEarningCard extends StatelessWidget {
  final ServiceEarning earning;
  const _ServiceEarningCard({required this.earning});

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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EEF5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(earning.serviceName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                ),
                Text(_fmt(earning.salaryAmount),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _InfoChip(icon: Icons.people_rounded, label: '${earning.studentCount} học viên'),
                const SizedBox(width: 12),
                _InfoChip(icon: Icons.percent_rounded, label: '${(earning.trainerPercentage * 100).toStringAsFixed(0)}%'),
                const SizedBox(width: 12),
                _InfoChip(icon: Icons.attach_money_rounded, label: _fmt(earning.servicePrice)),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: earning.trainerPercentage.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
            ),
          ],
        ),
      );
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      );
}
