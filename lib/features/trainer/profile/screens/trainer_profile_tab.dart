import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../../../auth/providers/auth_provider.dart';

class TrainerProfileTab extends StatelessWidget {
  const TrainerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: GradientContainer(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 84, height: 84,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
                          ),
                          child: Center(
                            child: Text(
                              user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'T',
                              style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -2, right: -2,
                          child: Container(
                            width: 26, height: 26,
                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFE8EEF5), width: 1.5)),
                            child: const Icon(Icons.camera_alt_rounded, size: 14, color: AppTheme.primaryBlue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(user?.fullName ?? '', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '', style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('🏋️ Personal Trainer',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _MenuSection(
                  label: 'Tài khoản',
                  items: [
                    _MenuItem(icon: Icons.person_outline, label: 'Thông tin cá nhân', onTap: () {}),
                    _MenuItem(icon: Icons.fitness_center_outlined, label: 'Chuyên môn', onTap: () {}),
                    _MenuItem(icon: Icons.star_outline, label: 'Đánh giá của tôi', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuSection(
                  label: 'Cài đặt',
                  items: [
                    _MenuItem(icon: Icons.notifications_outlined, label: 'Thông báo', onTap: () {}),
                    _MenuItem(icon: Icons.lock_outline, label: 'Bảo mật & Mật khẩu', onTap: () {}),
                    _MenuItem(icon: Icons.help_outline, label: 'Trợ giúp', onTap: () {}),
                  ],
                ),
                const SizedBox(height: 12),
                _LogoutButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String label;
  final List<_MenuItem> items;
  const _MenuSection({required this.label, required this.items});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EEF5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(label.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF), letterSpacing: 0.5)),
            ),
            ...items.asMap().entries.map((e) => Column(children: [
                  if (e.key > 0) const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFF5F7FB)),
                  e.value,
                ])),
          ],
        ),
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c)),
      trailing: color == null ? const Icon(Icons.chevron_right, color: Color(0xFFC7D2DA), size: 20) : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async {
          await context.read<AuthProvider>().logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
          }
        },
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
              Text('Đăng xuất', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C))),
            ],
          ),
        ),
      );
}
