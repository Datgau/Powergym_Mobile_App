import 'package:flutter/material.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import 'package_types.dart';

// ── Sample data ────────────────────────────────────────────────────
final TrainingPackage _activePackage = TrainingPackage(
  id: '1',
  name: 'Gói Premium 20 buổi',
  emoji: '🏆',
  totalSessions: 20,
  usedSessions: 12,
  startDate: DateTime(2026, 1, 1),
  endDate: DateTime(2026, 6, 30),
  trainerName: 'PT. Nguyễn Văn B',
  status: PackageStatus.active,
  price: 3800000,
);

final List<PackagePlan> _plans = [
  PackagePlan(
    name: 'Gói Starter',
    emoji: '🌱',
    sessions: '5 buổi',
    duration: '1 tháng',
    price: 1200000,
    features: ['Chọn PT tự do', 'Đặt lịch linh hoạt'],
    accentColor: const Color(0xFF059669),
  ),
  PackagePlan(
    name: 'Gói Gold',
    emoji: '🏆',
    sessions: '20 buổi',
    duration: '6 tháng',
    price: 3800000,
    features: ['PT chuyên biệt', 'Tư vấn dinh dưỡng', 'Đo lường tiến độ'],
    isPopular: true,
    accentColor: AppTheme.primaryBlue,
  ),
  PackagePlan(
    name: 'Gói Diamond VIP',
    emoji: '💎',
    sessions: '40 buổi',
    duration: '12 tháng',
    price: 6500000,
    features: [
      'Ưu tiên đặt lịch 24/7',
      'Kế hoạch cá nhân hóa AI',
      'Check-in không giới hạn',
    ],
    isVip: true,
    accentColor: const Color(0xFF1A202C),
  ),
];

final List<TrainingPackage> _history = [
  _activePackage,
  TrainingPackage(
    id: '0',
    name: 'Gói Starter 5 buổi',
    emoji: '🌱',
    totalSessions: 5,
    usedSessions: 5,
    startDate: DateTime(2025, 10, 1),
    endDate: DateTime(2025, 10, 31),
    trainerName: 'PT. Nguyễn Văn B',
    status: PackageStatus.expired,
    price: 1200000,
  ),
];

// ── Main tab ───────────────────────────────────────────────────────
class PackagesTab extends StatelessWidget {
  const PackagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Gradient header with active package ────────────────────
        SliverToBoxAdapter(
          child: GradientContainer(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + status badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gói tập của tôi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        _ActiveBadge(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Active package card
                    _ActivePackageCard(package: _activePackage),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Body ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFFF5F7FB),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Renewal reminder banner
                  _RenewalBanner(package: _activePackage),
                  const SizedBox(height: 20),

                  // Shop section
                  _SectionHeader(
                    title: 'Mua gói tập mới',
                    actionLabel: 'Xem tất cả',
                    onAction: () {},
                  ),
                  const SizedBox(height: 12),

                  // Starter + Gold row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _PlanCard(plan: _plans[0])),
                      const SizedBox(width: 10),
                      Expanded(child: _PlanCard(plan: _plans[1])),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Diamond VIP full-width
                  _PlanCardWide(plan: _plans[2]),
                  const SizedBox(height: 20),

                  // History section
                  _SectionHeader(
                    title: 'Lịch sử mua gói',
                    actionLabel: 'Xem tất cả',
                    onAction: () {},
                  ),
                  const SizedBox(height: 12),
                  ..._history.map(
                    (pkg) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _HistoryCard(package: pkg),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Active badge ───────────────────────────────────────────────────
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

// ── Active package card ────────────────────────────────────────────
class _ActivePackageCard extends StatelessWidget {
  final TrainingPackage package;
  const _ActivePackageCard({required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.4),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('★ ', style: TextStyle(color: Color(0xFFFFD700), fontSize: 12)),
                Text(
                  'GÓI GOLD — ĐANG DÙNG',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            package.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Có hiệu lực đến ${_fmt(package.endDate)} · ${package.trainerName}',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          // Progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đã sử dụng: ${package.usedSessions} buổi',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Còn lại: ${package.remainingSessions} buổi',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: package.progressPercent,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4ADE80),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Stats row
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _PackageStat(
                  value: '${package.totalSessions}',
                  label: 'Tổng buổi',
                ),
                _StatDivider(),
                _PackageStat(
                  value: '${package.remainingSessions}',
                  label: 'Còn lại',
                ),
                _StatDivider(),
                _PackageStat(
                  value: '${package.daysRemaining}',
                  label: 'Ngày còn lại',
                ),
                _StatDivider(),
                _PackageStat(
                  value: '6',
                  label: 'Tháng',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _PackageStat extends StatelessWidget {
  final String value;
  final String label;
  const _PackageStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withOpacity(0.08),
    );
  }
}

// ── Renewal banner ─────────────────────────────────────────────────
class _RenewalBanner extends StatelessWidget {
  final TrainingPackage package;
  const _RenewalBanner({required this.package});

  @override
  Widget build(BuildContext context) {
    if (package.remainingSessions > 5) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('🔔', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sắp hết buổi tập!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Còn ${package.remainingSessions} buổi — gia hạn ngay để không gián đoạn',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              elevation: 0,
            ),
            child: const Text(
              'Gia hạn',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ─────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A202C),
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Plan card (narrow — Starter / Gold) ───────────────────────────
class _PlanCard extends StatelessWidget {
  final PackagePlan plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: plan.isPopular
                  ? AppTheme.primaryBlue
                  : const Color(0xFFE8EEF5),
              width: plan.isPopular ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (plan.isPopular) const SizedBox(height: 10),
              Text(plan.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                plan.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A202C),
                ),
              ),
              Text(
                '${plan.sessions} · ${plan.duration}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _fmtPrice(plan.price),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: plan.accentColor,
                ),
              ),
              const Text(
                'đồng',
                style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 8),
              ...plan.features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            '✓',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          f,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: plan.isPopular
                        ? AppTheme.primaryBlue
                        : const Color(0xFFE8F0FE),
                    foregroundColor: plan.isPopular
                        ? Colors.white
                        : AppTheme.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  child: const Text(
                    'Mua ngay',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Popular badge
        if (plan.isPopular)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: const Text(
                'Phổ biến',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Plan card wide (Diamond VIP) ───────────────────────────────────
class _PlanCardWide extends StatelessWidget {
  final PackagePlan plan;
  const _PlanCardWide({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(plan.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A202C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'VIP',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${plan.sessions} · ${plan.duration} · Không giới hạn PT',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                ...plan.features.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              '✓',
                              style: TextStyle(
                                fontSize: 9,
                                color: Color(0xFF15803D),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          f,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: price + button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmtPrice(plan.price),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const Text(
                'đồng',
                style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                ),
                child: const Text(
                  'Nâng cấp',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── History card ───────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final TrainingPackage package;
  const _HistoryCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final isActive = package.status == PackageStatus.active;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFE8F0FE)
                  : const Color(0xFFF0F4F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                package.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmt(package.startDate)} → ${_fmt(package.endDate)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_fmtPrice(package.price)}đ',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isActive ? 'Đang dùng' : 'Đã hết hạn',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? const Color(0xFF15803D)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

// ── Helpers ────────────────────────────────────────────────────────
String _fmtPrice(double price) {
  final parts = price.toInt().toString().split('').reversed.toList();
  final result = <String>[];
  for (var i = 0; i < parts.length; i++) {
    if (i > 0 && i % 3 == 0) result.add('.');
    result.add(parts[i]);
  }
  return result.reversed.join();
}