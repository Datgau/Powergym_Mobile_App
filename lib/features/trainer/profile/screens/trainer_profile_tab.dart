import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/screens/login_screen.dart';
import '../../../profile/services/profile_api_service.dart';
import '../../../profile/screens/edit_profile_screen.dart';
import '../../../profile/screens/change_email_screen.dart';
import '../../providers/trainer_notification_provider.dart';

class TrainerProfileTab extends StatefulWidget {
  const TrainerProfileTab({super.key});

  @override
  State<TrainerProfileTab> createState() => _TrainerProfileTabState();
}

class _TrainerProfileTabState extends State<TrainerProfileTab> {
  final ProfileApiService _api = ProfileApiService();

  bool _notificationsEnabled = true;
  Map<String, dynamic>? _rawProfile;
  Map<String, dynamic>? _stats;
  bool _loadingExtra = true;

  @override
  void initState() {
    super.initState();
    _loadExtra();
  }

  Future<void> _loadExtra() async {
    try {
      final results = await Future.wait([
        _api.getProfile(),
        _fetchTrainerStats(),
      ]);
      if (mounted) {
        setState(() {
          _rawProfile = results[0] as Map<String, dynamic>?;
          _stats = results[1] as Map<String, dynamic>?;
          _loadingExtra = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingExtra = false);
    }
  }

  Future<Map<String, dynamic>> _fetchTrainerStats() async {
    // Placeholder - replace with actual API call
    return {
      'totalClients': 0,
      'totalSessions': 0,
      'rating': 0.0,
    };
  }

  Future<void> _logout() async {
    // Disconnect WebSocket before logout
    try {
      context.read<TrainerNotificationProvider>().disconnect();
    } catch (_) {}
    
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
    final user = context.watch<AuthProvider>().currentUser;
    final avatarUrl = _rawProfile?['avatar'] as String?;
    
    final totalClients = _stats?['totalClients'] as int? ?? 0;
    final totalSessions = _stats?['totalSessions'] as int? ?? 0;
    final rating = (_stats?['rating'] as num?)?.toDouble() ?? 0.0;

    return CustomScrollView(
      slivers: [
        // ── Hero header ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _ProfileHero(
            fullName: user?.fullName ?? 'Trainer',
            email: user?.email ?? '',
            avatarUrl: avatarUrl,
            totalClients: totalClients,
            totalSessions: totalSessions,
            rating: rating,
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
                  const SizedBox(height: 14),
                  
                  // ── Account menu ──────────────────────────────
                  _MenuCard(
                    sectionLabel: 'Account',
                    items: [
                      _MenuItem(
                        iconEmoji: '👤',
                        iconBg: const Color(0xFFE8F0FE),
                        label: 'Personal Info',
                        subtitle: user != null
                            ? '${user.fullName} · ${user.email}'
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
                        subtitle: user?.email ?? '',
                        onTap: () {
                          if (user == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeEmailScreen(
                                currentEmail: user.email,
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
                        iconEmoji: '🔔',
                        iconBg: const Color(0xFFFCE8E8),
                        label: 'Notifications',
                        subtitle: 'Booking alerts, reminders',
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
  final String fullName;
  final String email;
  final String? avatarUrl;
  final int totalClients;
  final int totalSessions;
  final double rating;

  const _ProfileHero({
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.totalClients,
    required this.totalSessions,
    required this.rating,
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
                  Text(fullName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3),
                  Text(email,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 10),
                  // Trainer badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('🏋️ Personal Trainer',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),

            // Stats strip
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
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;

  const _MenuItem({
    required this.iconEmoji,
    required this.iconBg,
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
