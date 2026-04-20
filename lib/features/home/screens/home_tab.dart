import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../providers/home_provider.dart';
import '../data/models/home_models.dart';
import '../../classes/screens/community_screen.dart';
import '../../classes/screens/my_classes_screen.dart';

class HomeTab extends StatelessWidget {
  final void Function(int)? onTabChange;
  const HomeTab({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_, provider, __) {
        final profile = provider.profile;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
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
                                  const Text(
                                    'Hello 👋',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    profile?.firstName ?? '...',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => onTabChange?.call(4),
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: profile?.avatar != null
                                      ? ClipOval(
                                          child: Image.network(
                                            profile!.avatar!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(Icons.person,
                                                    color: Colors.white, size: 28),
                                          ),
                                        )
                                      : const Icon(Icons.person,
                                          color: Colors.white, size: 28),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // Stats strip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatChip(
                                  label: 'Services',
                                  value: '${provider.activeServiceCount}',
                                ),
                                _Divider(),
                                _StatChip(
                                  label: 'Memberships',
                                  value: '${provider.activeMembershipCount}',
                                ),
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

            // ── Body ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
            child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            /// ================= QUICK ACTIONS =================
            _SectionHeader(title: 'Quick Actions'),
            const SizedBox(height: 12),

            LayoutBuilder(
            builder: (context, constraints) {
            final width = constraints.maxWidth;

            int crossAxisCount = 2;
            if (width > 600) crossAxisCount = 3;

            return GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
            QuickActionCard(
            icon: Icons.calendar_month_rounded,
            title: 'Appointments',
            subtitle: 'Services',
            color: AppTheme.primaryBlue,
            onTap: () => onTabChange?.call(1),
            ),
            QuickActionCard(
            icon: Icons.card_membership_rounded,
            title: 'Membership & Service',
            subtitle: 'View plans',
            color: AppTheme.darkBlue,
            onTap: () => onTabChange?.call(2),
            ),
            QuickActionCard(
            icon: Icons.groups_rounded,
            title: 'Community',
            subtitle: 'Classes',
            color: const Color(0xFF8B5CF6),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommunityScreen()),
            ),
            ),
            QuickActionCard(
            icon: Icons.history_rounded,
            title: 'My Classes',
            subtitle: 'History',
            color: const Color(0xFFF59E0B),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyClassesScreen()),
            ),
            ),
            ],
            );
            },
            ),

            const SizedBox(height: 28),

            /// ================= LOADING / ERROR =================
            if (provider.isLoading)
            const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
        )
        else if (provider.status == HomeStatus.error)
        _ErrorCard(
        message: provider.error,
        onRetry: provider.loadAll,
        )
        else ...[
        /// ================= MEMBERSHIPS =================
        if (provider.activeMemberships.isNotEmpty) ...[
        _SectionHeader(title: 'Registered Memberships'),
        const SizedBox(height: 12),

        ListView.separated(
        itemCount: provider.activeMemberships.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) =>
        _MembershipCard(item: provider.activeMemberships[i]),
        ),

        const SizedBox(height: 20),
        ],

        /// ================= SERVICES =================
        if (provider.serviceRegistrations.isNotEmpty) ...[
        _SectionHeader(title: 'Registered Services'),
        const SizedBox(height: 12),

        ListView.separated(
        itemCount: provider.serviceRegistrations.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) =>
        _ServiceCard(item: provider.serviceRegistrations[i]),
        ),
        ],

        /// ================= EMPTY =================
        if (provider.activeMemberships.isEmpty &&
        provider.serviceRegistrations.isEmpty)
        _EmptyState(),
        ],
        ],
        ),
        ),
        ),
          ],
        );
      },
    );
  }
}

// ── Stat chip ──────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: Colors.white.withOpacity(0.25));
}

// ── Section header ─────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTheme.textPrimary,
          letterSpacing: -0.3,
        ),
      );
}

// ── Membership Card ────────────────────────────────────────────────────────
class _MembershipCard extends StatelessWidget {
  final ActiveMembershipItem item;
  const _MembershipCard({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case 'ACTIVE': return const Color(0xFF10B981);
      case 'EXPIRED': return const Color(0xFF6B7280);
      case 'CANCELLED': return const Color(0xFFEF4444);
      default: return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.description_outlined,
                    color: AppTheme.primaryBlue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Contract',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package name + status
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined,
                        color: AppTheme.primaryBlue, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.packageName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _statusColor.withOpacity(0.4), width: 1),
                      ),
                      child: Text(
                        item.statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats row
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoStat(
                          icon: Icons.check_circle_outline,
                          iconColor: AppTheme.primaryBlue,
                          label: 'Trained',
                          value: '${_daysTrained()}',
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 36,
                          color: const Color(0xFFE0E0E0)),
                      Expanded(
                        child: _InfoStat(
                          icon: Icons.battery_charging_full_rounded,
                          iconColor: const Color(0xFF10B981),
                          label: 'Remaining',
                          value: '${item.remainingDays}',
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 36,
                          color: const Color(0xFFE0E0E0)),
                      Expanded(
                        child: _InfoStat(
                          icon: Icons.calendar_month_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          label: 'Expires',
                          value: item.formatDate(item.endDate),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Dates row
                Row(
                  children: [
                    Expanded(
                      child: _LabelValue(
                          label: 'Start date',
                          value: item.formatDate(item.startDate)),
                    ),
                    Expanded(
                      child: _LabelValue(
                          label: 'Value',
                          value: item.formattedPrice),
                    ),
                    Expanded(
                      child: _LabelValue(
                          label: 'Duration',
                          value: '${item.duration} days'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _daysTrained() {
    try {
      if (item.startDate.isEmpty) return 0;
      final start = DateTime.parse(item.startDate);
      final days = DateTime.now().difference(start).inDays;
      return days > 0 ? days : 0;
    } catch (_) {
      return 0;
    }
  }
}

// ── Service Card ───────────────────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final ServiceRegistrationItem item;
  const _ServiceCard({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case 'ACTIVE':
        if (item.bookingStatus == 'REJECTED' || item.bookingStatus == 'CANCELLED') {
          return const Color(0xFFEF4444);
        }
        return const Color(0xFF10B981);
      case 'CONFIRMED': return AppTheme.primaryBlue;
      case 'PENDING': return const Color(0xFFF59E0B);
      case 'EXPIRED': return const Color(0xFF6B7280);
      case 'CANCELLED': return const Color(0xFFEF4444);
      case 'COMPLETED': return const Color(0xFF6B7280);
      default: return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.fitness_center_rounded,
                    color: AppTheme.primaryBlue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Service',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service name + status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.serviceName ?? 'Service',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _statusColor.withOpacity(0.4), width: 1),
                      ),
                      child: Text(
                        item.statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                // Trainer
                if (item.trainerName != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      item.trainerAvatar != null
                          ? ClipOval(
                              child: Image.network(
                                item.trainerAvatar!,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person,
                                      size: 14, color: AppTheme.primaryBlue),
                                ),
                              ),
                            )
                          : Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person,
                                  size: 14, color: AppTheme.primaryBlue),
                            ),
                      const SizedBox(width: 6),
                      Text(
                        'Trainer: ${item.trainerName}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                // Info grid
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _InfoStat(
                          icon: Icons.calendar_today_outlined,
                          iconColor: AppTheme.primaryBlue,
                          label: 'Start',
                          value: item.formatDate(item.startDate),
                        ),
                      ),
                      Container(
                          width: 1,
                          height: 36,
                          color: const Color(0xFFE0E0E0)),
                      Expanded(
                        child: _InfoStat(
                          icon: Icons.event_outlined,
                          iconColor: const Color(0xFFEF4444),
                          label: 'End',
                          value: item.formatDate(item.endDate),
                        ),
                      ),
                      if (item.duration != null) ...[
                        Container(
                            width: 1,
                            height: 36,
                            color: const Color(0xFFE0E0E0)),
                        Expanded(
                          child: _InfoStat(
                            icon: Icons.timer_outlined,
                            iconColor: const Color(0xFF8B5CF6),
                            label: 'Duration',
                            value: '${item.duration} min',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (item.formattedPrice.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _LabelValue(
                            label: 'Price',
                            value: item.formattedPrice),
                      ),
                      if (item.registrationDate != null)
                        Expanded(
                          child: _LabelValue(
                              label: 'Registered on',
                              value: item.formatDate(item.registrationDate)),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Stat widget ───────────────────────────────────────────────────────
class _InfoStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _InfoStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Label Value ────────────────────────────────────────────────────────────
class _LabelValue extends StatelessWidget {
  final String label;
  final String value;
  const _LabelValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
      ],
    );
  }
}

// ── Error Card ─────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.error.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error),
            const SizedBox(width: 10),
            Expanded(
                child: Text(message,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textPrimary))),
            TextButton(
                onPressed: onRetry,
                child: const Text('Retry',
                    style: TextStyle(color: AppTheme.primaryBlue))),
          ],
        ),
      );
}

// ── Empty State ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8EEF5)),
        ),
        child: Column(
          children: [
            const Text('🏋️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text(
              'No services or memberships yet',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Register a service or membership to get started!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary.withOpacity(0.8)),
            ),
          ],
        ),
      );
}

// ── Quick Action Card ──────────────────────────────────────────────────────
class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.2), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.2)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
