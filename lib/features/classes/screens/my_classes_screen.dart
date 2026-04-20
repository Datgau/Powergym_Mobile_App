import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../../home/providers/home_provider.dart';
import '../../home/data/models/home_models.dart';

class MyClassesScreen extends StatelessWidget {
  const MyClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_, provider, __) {
        // Only show registrations where trainer has NOT rejected
        final registrations = provider.serviceRegistrations
            .where((s) => s.bookingStatus != 'REJECTED')
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          body: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 130,
                floating: false,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: GradientContainer(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('My Classes',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(
                              provider.isLoading
                                  ? 'Loading...'
                                  : '${registrations.length} class${registrations.length != 1 ? 'es' : ''}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: Colors.white70),
                    onPressed: () => provider.loadAll(),
                  ),
                ],
              ),

              // ── Content ──────────────────────────────────────────
              if (provider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (registrations.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏋️', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        const Text('No classes yet',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary)),
                        const SizedBox(height: 8),
                        Text(
                          'Register for a service to see it here',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _MyClassCard(item: registrations[i]),
                      ),
                      childCount: registrations.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── My class card ──────────────────────────────────────────────────
class _MyClassCard extends StatelessWidget {
  final ServiceRegistrationItem item;
  const _MyClassCard({required this.item});

  // Only show trainer if booking is confirmed/pending (not rejected/cancelled)
  bool get _hasValidTrainer {
    if (item.trainerName == null) return false;
    if (item.bookingStatus == 'REJECTED' ||
        item.bookingStatus == 'CANCELLED') return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = item.serviceImages.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ──────────────────────────────────────────────
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: hasImage
                ? Image.network(
                    item.serviceImages.first,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Placeholder(),
                  )
                : _Placeholder(),
          ),

          // ── Info ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  item.serviceName ?? 'Service',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 10),

                // Trainer (only if not rejected)
                if (_hasValidTrainer) ...[
                  Row(
                    children: [
                      item.trainerAvatar != null
                          ? ClipOval(
                              child: Image.network(
                                item.trainerAvatar!,
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _AvatarFallback(),
                              ),
                            )
                          : _AvatarFallback(),
                      const SizedBox(width: 6),
                      Text(
                        item.trainerName!,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // Stats row
                Row(
                  children: [
                    // Member count
                    if (item.memberCount != null) ...[
                      _InfoChip(
                        icon: Icons.people_outline,
                        label: '${item.memberCount} members',
                        color: AppTheme.primaryBlue,
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Date range
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label:
                            '${item.formatDate(item.startDate)} – ${item.formatDate(item.endDate)}',
                        color: const Color(0xFF059669),
                      ),
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
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withOpacity(0.6),
            AppTheme.primaryBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.fitness_center_rounded,
            color: Colors.white54, size: 40),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 14, color: AppTheme.primaryBlue),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
