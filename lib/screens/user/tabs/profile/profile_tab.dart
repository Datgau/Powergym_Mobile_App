import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../../../../features/home/providers/home_provider.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/auth/screens/login_screen.dart';
import 'profile_types.dart';

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

const _achievements = [
  Achievement(emoji: '🔥', name: 'Streak 8 tuần', subtitle: 'Đang duy trì', unlocked: true),
  Achievement(emoji: '💪', name: '30 buổi tập', subtitle: 'Đã đạt', unlocked: true),
  Achievement(emoji: '🏅', name: '50 buổi tập', subtitle: '18 buổi nữa', unlocked: false),
  Achievement(emoji: '👑', name: 'Diamond', subtitle: 'Nâng cấp VIP', unlocked: false),
];

const _favoriteTrainers = [
  FavoriteTrainer(
    name: 'PT. Nguyễn Văn B',
    specialty: 'Gym & Strength',
    rating: 4.9,
    emoji: '💪',
    color: AppTheme.primaryBlue,
  ),
  FavoriteTrainer(
    name: 'PT. Trần Thị C',
    specialty: 'Yoga & Flexibility',
    rating: 4.8,
    emoji: '🧘',
    color: Color(0xFF7C3AED),
  ),
];

// ── Main tab ───────────────────────────────────────────────────────
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notificationsEnabled = true;

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

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final apiProfile = homeProvider.profile;

    // Map API data to local UserProfile type (keep existing UI unchanged)
    final profile = apiProfile != null
        ? UserProfile(
            fullName: apiProfile.fullName,
            email: apiProfile.email,
            phone: apiProfile.phoneNumber ?? '',
            membershipTier: apiProfile.role == 'TRAINER' ? 'Trainer' : 'Member',
            memberSince: DateTime.now(),
            totalSessions: 0,
            weekStreak: 0,
            trainerRating: 0,
            weightGoalKg: 0,
            currentWeightKg: 0,
            heightCm: 0,
          )
        : _defaultProfile;

    return CustomScrollView(
      slivers: [
        // ── Hero header ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _ProfileHero(
            profile: profile,
            onEditTap: () {},
          ),
        ),

        // ── Scrollable body ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFFF5F7FB),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Achievements
                const _SectionTitle(title: 'Thành tích'),
                const SizedBox(height: 8),
                _AchievementsRow(achievements: _achievements),
                const SizedBox(height: 14),

                // Account info
                _MenuCard(
                  sectionLabel: 'Tài khoản',
                  items: [
                    _MenuItem(
                      iconEmoji: '👤',
                      iconBg: const Color(0xFFE8F0FE),
                      label: 'Thông tin cá nhân',
                      subtitle: 'Tên, SĐT, ngày sinh',
                      onTap: () {},
                    ),
                    _MenuItem(
                      iconEmoji: '🎯',
                      iconBg: const Color(0xFFE8FCE8),
                      label: 'Mục tiêu tập luyện',
                      subtitle: 'Giảm cân · ${profile.weightGoalKg.toInt()}kg · 6 tháng',
                      onTap: () {},
                    ),
                    _MenuItem(
                      iconEmoji: '📏',
                      iconBg: const Color(0xFFFEF5E8),
                      label: 'Chỉ số cơ thể',
                      subtitle:
                          '${profile.currentWeightKg.toInt()}kg · ${profile.heightCm.toInt()}cm · BMI ${profile.bmi.toStringAsFixed(1)}',
                      trailing: const _BlueBadge(label: 'Cập nhật'),
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Favorite trainers
                _MenuCard(
                  sectionLabel: 'Trainer yêu thích',
                  items: _favoriteTrainers
                      .map(
                        (t) => _MenuItem(
                          iconEmoji: t.emoji,
                          iconBg: t.color,
                          iconEmojiOnColor: true,
                          label: t.name,
                          subtitle: '${t.specialty} · ★ ${t.rating}',
                          onTap: () {},
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),

                // Settings
                _MenuCard(
                  sectionLabel: 'Cài đặt',
                  items: [
                    _MenuItem(
                      iconEmoji: '🔔',
                      iconBg: const Color(0xFFFCE8E8),
                      label: 'Thông báo',
                      subtitle: 'Nhắc lịch tập, khuyến mãi',
                      trailing: Switch(
                        value: _notificationsEnabled,
                        onChanged: (v) =>
                            setState(() => _notificationsEnabled = v),
                        activeColor: AppTheme.primaryBlue,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      showChevron: false,
                    ),
                    _MenuItem(
                      iconEmoji: '🌐',
                      iconBg: const Color(0xFFE8EEF5),
                      label: 'Ngôn ngữ',
                      subtitle: 'Tiếng Việt',
                      onTap: () {},
                    ),
                    _MenuItem(
                      iconEmoji: '🔒',
                      iconBg: const Color(0xFFFEF5E8),
                      label: 'Bảo mật & Mật khẩu',
                      onTap: () {},
                    ),
                    _MenuItem(
                      iconEmoji: '⭐',
                      iconBg: const Color(0xFFF0F4F8),
                      label: 'Đánh giá ứng dụng',
                      onTap: () {},
                    ),
                    _MenuItem(
                      iconEmoji: '❓',
                      iconBg: const Color(0xFFE8F0FE),
                      label: 'Trợ giúp & Hỗ trợ',
                      trailing: const _RedBadge(label: '2'),
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Logout
                _LogoutButton(
                  onTap: _logout,
                ),
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
  final VoidCallback onEditTap;

  const _ProfileHero({required this.profile, required this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Edit button row
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                onTap: onEditTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 13, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        'Chỉnh sửa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Avatar + name
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 3,
                          ),
                        ),
                        child: const Center(
                          child:
                              Text('🧑', style: TextStyle(fontSize: 36)),
                        ),
                      ),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: const Color(0xFFE8EEF5),
                              width: 1.5,
                            ),
                          ),
                          child: const Center(
                            child: Text('📷',
                                style: TextStyle(fontSize: 13)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    profile.email,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '★ ',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${profile.membershipTier} · Từ ${_fmtDate(profile.memberSince)}',
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
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
                      value: '${profile.totalSessions}', label: 'Buổi tập'),
                  _HeroStatDivider(),
                  _HeroStat(
                      value: '${profile.weekStreak}', label: 'Tuần streak'),
                  _HeroStatDivider(),
                  _HeroStat(
                      value: profile.trainerRating.toStringAsFixed(1),
                      label: 'Điểm PT'),
                  _HeroStatDivider(),
                  _HeroStat(
                      value: '${profile.weightGoalKg.toInt()}kg',
                      label: 'Mục tiêu'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.year}';
}

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

// ── Achievements row ───────────────────────────────────────────────
class _AchievementsRow extends StatelessWidget {
  final List<Achievement> achievements;
  const _AchievementsRow({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: achievements
          .map(
            (a) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Opacity(
                  opacity: a.unlocked ? 1.0 : 0.4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8EEF5)),
                    ),
                    child: Column(
                      children: [
                        Text(a.emoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 6),
                        Text(
                          a.name,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.subtitle,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
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

// ── Badge widgets ──────────────────────────────────────────────────
class _BlueBadge extends StatelessWidget {
  final String label;
  const _BlueBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }
}

class _RedBadge extends StatelessWidget {
  final String label;
  const _RedBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFFB91C1C),
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
              'Đăng xuất',
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