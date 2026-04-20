import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../../home/providers/home_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../models/profile_types.dart';
import '../services/profile_api_service.dart';
import 'edit_profile_screen.dart';
import 'change_email_screen.dart';

// ── Default profile (fallback) ─────────────────────────────────────
final _defaultProfile = UserProfile(
  fullName: 'Loading...',
  email: '',
  phone: '',
  membershipTier: 'Member',
  memberSince: DateTime.now(),
  totalSessions: 0,
  weekStreak: 0,
  trainerRating: 0,
  weightGoalKg: 0,
  currentWeightKg: 0,
  heightCm: 0,
);

// ── Main tab ───────────────────────────────────────────────────────
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final ProfileApiService _api = ProfileApiService();

  bool _notificationsEnabled = true;
  Map<String, dynamic>? _rewards;
  List<Map<String, dynamic>> _memberships = [];
  List<Map<String, dynamic>> _orders = [];
  bool _loadingExtra = true;
  Map<String, dynamic>? _rawProfile; // raw profile for edit screen

  @override
  void initState() {
    super.initState();
    _loadExtra();
  }

  Future<void> _loadExtra() async {
    try {
      final results = await Future.wait([
        _api.getRewards(),
        _api.getMemberships(),
        _api.getRecentOrders(),
        _api.getProfile(),
      ]);
      if (mounted) {
        setState(() {
          _rewards = results[0] as Map<String, dynamic>?;
          _memberships = results[1] as List<Map<String, dynamic>>;
          _orders = results[2] as List<Map<String, dynamic>>;
          _rawProfile = results[3] as Map<String, dynamic>?;
          _loadingExtra = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingExtra = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthLoginScreen()),
        (_) => false,
      );
    }
  }

  void _showChangePasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Change Password',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PwField(ctrl: oldCtrl, label: 'Current password'),
                const SizedBox(height: 12),
                _PwField(ctrl: newCtrl, label: 'New password'),
                const SizedBox(height: 12),
                _PwField(ctrl: confirmCtrl, label: 'Confirm new password'),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setS(() => loading = true);
                      try {
                        await _api.changePassword(
                          oldPassword: oldCtrl.text,
                          newPassword: newCtrl.text,
                          confirmPassword: confirmCtrl.text,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed successfully'),
                              backgroundColor: AppTheme.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setS(() => loading = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: AppTheme.error,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final apiProfile = homeProvider.profile;

    final profile = apiProfile != null
        ? UserProfile(
            fullName: apiProfile.fullName,
            email: apiProfile.email,
            phone: apiProfile.phoneNumber ?? '',
            membershipTier: apiProfile.role == 'TRAINER' ? 'Trainer' : 'Member',
            memberSince: DateTime.now(),
            totalSessions: homeProvider.bookings.length,
            weekStreak: 0,
            trainerRating: 0,
            weightGoalKg: 0,
            currentWeightKg: 0,
            heightCm: 0,
          )
        : _defaultProfile;

    // Reward data
    final totalPoints = (_rewards?['totalPoints'] as num?)?.toInt() ?? 0;
    final memberLevel = _rewards?['membershipLevelDisplay'] as String? ?? 'Member';
    final pointsToNext = (_rewards?['pointsToNextLevel'] as num?)?.toInt() ?? 0;

    // Active membership
    final activeMembership = _memberships.where((m) {
      return (m['status'] as String? ?? '') == 'ACTIVE';
    }).toList();

    return CustomScrollView(
      slivers: [
        // ── Hero header ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _ProfileHero(
            profile: profile,
            memberLevel: memberLevel,
            totalPoints: totalPoints,
            activeMembershipCount: activeMembership.length,
            bookingCount: homeProvider.bookings.length,
            avatarUrl: _rawProfile?['avatar'] as String?,
          ),
        ),

        // ── Body ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFFF5F7FB),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Rewards card ──────────────────────────────
                  if (!_loadingExtra && _rewards != null) ...[
                    const _SectionTitle(title: 'Rewards'),
                    const SizedBox(height: 8),
                    _RewardsCard(
                      totalPoints: totalPoints,
                      memberLevel: memberLevel,
                      pointsToNext: pointsToNext,
                      nextLevel: _rewards?['nextLevel'] as String? ?? '',
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Active memberships ────────────────────────
                  if (!_loadingExtra && activeMembership.isNotEmpty) ...[
                    const _SectionTitle(title: 'Active Memberships'),
                    const SizedBox(height: 8),
                    ...activeMembership.take(2).map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _MembershipCard(data: m),
                        )),
                    const SizedBox(height: 14),
                  ],

                  // ── Recent orders ─────────────────────────────
                  // (moved into Order History menu item below)

                  // ── Account menu ──────────────────────────────
                  _MenuCard(
                    sectionLabel: 'Account',
                    items: [
                      _MenuItem(
                        iconEmoji: '👤',
                        iconBg: const Color(0xFFE8F0FE),
                        label: 'Personal Info',
                        subtitle: apiProfile != null
                            ? '${apiProfile.fullName} · ${apiProfile.email}'
                            : 'Name, phone, date of birth',
                        onTap: () {
                          if (_rawProfile == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                profile: _rawProfile!,
                                onUpdated: () {
                                  _loadExtra();
                                  context.read<HomeProvider>().loadAll();
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      _MenuItem(
                        iconEmoji: '📧',
                        iconBg: const Color(0xFFE8FCE8),
                        label: 'Change Email',
                        subtitle: apiProfile?.email ?? '',
                        onTap: () {
                          if (apiProfile == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeEmailScreen(
                                currentEmail: apiProfile.email,
                                onChanged: () {
                                  context.read<AuthProvider>().logout();
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const AuthLoginScreen()),
                                    (_) => false,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      _MenuItem(
                        iconEmoji: '🔒',
                        iconBg: const Color(0xFFFEF5E8),
                        label: 'Change Password',
                        subtitle: 'Update your password',
                        onTap: _showChangePasswordDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Settings ──────────────────────────────────
                  _MenuCard(
                    sectionLabel: 'Settings',
                    items: [
                      _MenuItem(
                        iconEmoji: '🛍️',
                        iconBg: const Color(0xFFE8F0FE),
                        label: 'Order History',
                        subtitle: _orders.isEmpty
                            ? 'No orders yet'
                            : '${_orders.length} recent order${_orders.length > 1 ? 's' : ''}',
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => _OrderHistorySheet(orders: _orders),
                          );
                        },
                      ),
                      _MenuItem(
                        iconEmoji: '🔔',
                        iconBg: const Color(0xFFFCE8E8),
                        label: 'Notifications',
                        subtitle: 'Schedule reminders, promotions',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (v) =>
                              setState(() => _notificationsEnabled = v),
                          activeColor: AppTheme.primaryBlue,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        showChevron: false,
                      ),
                      _MenuItem(
                        iconEmoji: '⭐',
                        iconBg: const Color(0xFFF0F4F8),
                        label: 'Rate the app',
                        onTap: () {},
                      ),
                      _MenuItem(
                        iconEmoji: '❓',
                        iconBg: const Color(0xFFE8F0FE),
                        label: 'Help & Support',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Logout ────────────────────────────────────
                  _LogoutButton(onTap: _logout),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Profile hero ───────────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  final UserProfile profile;
  final String memberLevel;
  final int totalPoints;
  final int activeMembershipCount;
  final int bookingCount;
  final String? avatarUrl;

  const _ProfileHero({
    required this.profile,
    required this.memberLevel,
    required this.totalPoints,
    required this.activeMembershipCount,
    required this.bookingCount,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Avatar + name
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 10),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23),
                      child: avatarUrl != null && avatarUrl!.isNotEmpty
                          ? Image.network(
                              avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.person,
                                    color: Colors.white, size: 40),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 40),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(profile.fullName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(profile.email,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 10),
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFFFD700).withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('★ ',
                            style: TextStyle(
                                color: Color(0xFFFFD700), fontSize: 13)),
                        Text(
                          '$memberLevel · $totalPoints pts',
                          style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats strip
            Container(
              color: Colors.black.withOpacity(0.18),
              child: Row(
                children: [
                  _HeroStat(
                      value: '$bookingCount', label: 'Bookings'),
                  _HeroStatDivider(),
                  _HeroStat(
                      value: '$activeMembershipCount', label: 'Memberships'),
                  _HeroStatDivider(),
                  _HeroStat(
                      value: '$totalPoints', label: 'Points'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Password field helper ──────────────────────────────────────────
class _PwField extends StatefulWidget {
  final TextEditingController ctrl;
  final String label;
  const _PwField({required this.ctrl, required this.label});

  @override
  State<_PwField> createState() => _PwFieldState();
}

class _PwFieldState extends State<_PwField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.ctrl,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }
}

// ── Rewards card ───────────────────────────────────────────────────
class _RewardsCard extends StatelessWidget {
  final int totalPoints;
  final String memberLevel;
  final int pointsToNext;
  final String nextLevel;

  const _RewardsCard({
    required this.totalPoints,
    required this.memberLevel,
    required this.pointsToNext,
    required this.nextLevel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = pointsToNext > 0
        ? (totalPoints / (totalPoints + pointsToNext)).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(memberLevel,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                  Text('$totalPoints pts',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.stars_rounded,
                    color: Color(0xFFFFD700), size: 24),
              ),
            ],
          ),
          if (nextLevel.isNotEmpty && pointsToNext > 0) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$pointsToNext pts to $nextLevel',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Membership card ────────────────────────────────────────────────
class _MembershipCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _MembershipCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final pkg = data['membershipPackage'] as Map<String, dynamic>? ?? {};
    final name = pkg['name'] as String? ?? 'Membership';
    final endDate = data['endDate'] as String? ?? '';
    final status = data['status'] as String? ?? '';

    DateTime? end;
    int daysLeft = 0;
    try {
      end = DateTime.parse(endDate);
      daysLeft = end.difference(DateTime.now()).inDays;
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.card_membership_rounded,
                color: AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A202C))),
                const SizedBox(height: 2),
                Text(
                  end != null
                      ? 'Expires ${end.day}/${end.month}/${end.year} · $daysLeft days left'
                      : status,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status == 'ACTIVE' ? 'Active' : status,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15803D)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order History Bottom Sheet ─────────────────────────────────────
class _OrderHistorySheet extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  const _OrderHistorySheet({required this.orders});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Text('Order History',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // List
            Expanded(
              child: orders.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🛍️', style: TextStyle(fontSize: 40)),
                          SizedBox(height: 12),
                          Text('No orders yet',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: ctrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _OrderTile(order: orders[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final amount = order['totalAmount'];
    final payStatus = order['paymentStatus'] as String? ?? '';
    final delivery = order['deliveryStatus'] as String? ?? '';
    final items = order['itemCount'] as int? ?? 0;
    final createdAt = order['createdAt'] as String? ?? '';

    String dateStr = '';
    try {
      final dt = DateTime.parse(createdAt);
      dateStr =
          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {}

    final deliveryColor = delivery == 'DELIVERED'
        ? const Color(0xFF10B981)
        : delivery == 'CANCELLED'
            ? const Color(0xFFEF4444)
            : const Color(0xFFF59E0B);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                color: AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${order['id']} · $items item${items > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text(dateStr,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount != null ? '${_fmt(amount)}đ' : '',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: deliveryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  delivery,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: deliveryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(dynamic amount) {
    try {
      final n = (amount as num).toInt();
      return n
          .toString()
          .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]}.');
    } catch (_) {
      return amount.toString();
    }
  }
}

// ── Orders card ────────────────────────────────────────────────────
class _OrdersCard extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  const _OrdersCard({required this.orders});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Column(
        children: orders.asMap().entries.map((e) {
          final order = e.value;
          final amount = order['totalAmount'];
          final status = order['paymentStatus'] as String? ?? '';
          final delivery = order['deliveryStatus'] as String? ?? '';
          final items = order['itemCount'] as int? ?? 0;
          final createdAt = order['createdAt'] as String? ?? '';

          String dateStr = '';
          try {
            final dt = DateTime.parse(createdAt);
            dateStr = '${dt.day}/${dt.month}/${dt.year}';
          } catch (_) {}

          return Column(
            children: [
              if (e.key > 0)
                const Divider(height: 1, indent: 16, endIndent: 16,
                    color: Color(0xFFF5F7FB)),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          size: 18, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order #${order['id']} · $items items',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A202C))),
                          Text('$dateStr · $delivery',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amount != null
                              ? '${_fmt(amount)}d'
                              : '',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A202C)),
                        ),
                        Text(status,
                            style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9CA3AF))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _fmt(dynamic amount) {
    try {
      final n = (amount as num).toInt();
      return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    } catch (_) {
      return amount.toString();
    }
  }
}

// ── HeroStat ───────────────────────────────────────────────────────
class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
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

class _HeroStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: Colors.white.withOpacity(0.07));
}

// ── Section title ──────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A202C),
          ),
        ),
      );
}

// ── Menu card + item ───────────────────────────────────────────────
class _MenuCard extends StatelessWidget {
  final String sectionLabel;
  final List<_MenuItem> items;

  const _MenuCard({required this.sectionLabel, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              sectionLabel.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...items.asMap().entries.map(
                (e) => Column(
                  children: [
                    if (e.key > 0)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFF5F7FB),
                      ),
                    e.value,
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String iconEmoji;
  final Color iconBg;
  final bool iconEmojiOnColor;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const _MenuItem({
    required this.iconEmoji,
    required this.iconBg,
    this.iconEmojiOnColor = false,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  iconEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Label + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Trailing
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 6),
            ],
            if (showChevron)
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: Color(0xFFC7D2DA),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Logout button ──────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🚪', style: TextStyle(fontSize: 16)),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFB91C1C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}