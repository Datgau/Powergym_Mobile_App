import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../../../widgets/gradient_container.dart';
import '../../../../models/membership_package.dart';
import '../../../../services/packages_service.dart';
// Import BottomSheet chọn phương thức thanh toán đúng đường dẫn
import '../../widgets/payment_method_bottom_sheet.dart';

// ── Hàm tiện ích chuyển đổi mã màu HEX từ Backend sang Color của Flutter ──
Color _parseColor(String? colorHex) {
  if (colorHex == null || colorHex.isEmpty) return AppTheme.primaryBlue;
  try {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  } catch (e) {
    return AppTheme.primaryBlue;
  }
}

// ── Main tab ───────────────────────────────────────────────────────
class PackagesTab extends StatefulWidget {
  const PackagesTab({super.key});

  @override
  State<PackagesTab> createState() => _PackagesTabState();
}

class _PackagesTabState extends State<PackagesTab> {
  final PackagesService _packagesService = PackagesService();
  late Future<List<MembershipPackage>> _packagesFuture;

  @override
  void initState() {
    super.initState();
    // Gọi API lấy danh sách gói tập đang Active từ Backend
    _packagesFuture = _packagesService.getAvailablePackages();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Gradient header with active package ────
        SliverToBoxAdapter(
          child: GradientContainer(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    // Có thể thay thế bằng dữ liệu Gói đang dùng thực tế của User sau này
                    const Text(
                      'Bạn chưa có gói tập nào đang hoạt động.',
                      style: TextStyle(color: Colors.white70),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Section header ─────────────────────────────────────────────────
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: _SectionHeader(title: 'Mua gói tập mới'),
          ),
        ),

        // ── Danh sách gói tập (Gọi từ API) ─────────────────────────────────
        SliverToBoxAdapter(
          child: FutureBuilder<List<MembershipPackage>>(
            future: _packagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                      child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.red))
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text('Hiện không có gói tập nào.')),
                );
              }

              final packages = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: packages.map((package) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      // Tự động render Gói VIP hoặc Gói Thường dựa trên mức giá
                      child: package.price > 5000000
                          ? _PlanCardWide(package: package)
                          : _PlanCard(package: package),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),

        // Tăng khoảng trống ở cuối để không bị BottomNavigationBar che khuất
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// ── Các Component phụ trợ ─────────
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A202C),
      ),
    );
  }
}

// ── Card hiển thị Gói Thường ───────────
class _PlanCard extends StatelessWidget {
  final MembershipPackage package;
  const _PlanCard({required this.package});

  @override
  Widget build(BuildContext context) {
    final themeColor = _parseColor(package.color);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: package.isPopular ? themeColor : const Color(0xFFE8EEF5),
              width: package.isPopular ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (package.isPopular) const SizedBox(height: 10),
              const Text('💎', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text(
                package.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A202C),
                ),
              ),
              Text(
                package.durationText,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    package.formattedPrice,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: themeColor,
                    ),
                  ),
                  if (package.originalPrice != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      package.formattedOriginalPrice,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ]
                ],
              ),
              const SizedBox(height: 12),

              // Features
              ...package.features.map(
                    (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
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
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          f,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // BƯỚC 5.2: Gắn BottomSheet chọn phương thức thanh toán vào đây
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => PaymentMethodBottomSheet(package: package),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: package.isPopular ? themeColor : const Color(0xFFE8F0FE),
                    foregroundColor: package.isPopular ? Colors.white : AppTheme.primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Mua ngay',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Badge Phổ biến
        if (package.isPopular)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: const Text(
                'PHỔ BIẾN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Card hiển thị Gói VIP ──────────────
class _PlanCardWide extends StatelessWidget {
  final MembershipPackage package;
  const _PlanCardWide({required this.package});

  @override
  Widget build(BuildContext context) {
    final themeColor = _parseColor(package.color);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8EEF5)),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trái: Thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      const Text('👑', style: TextStyle(fontSize: 20)),
                      Text(
                        package.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A202C),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    package.durationText,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 8),
                  ...package.features.take(2).map(
                        (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 14, color: Color(0xFF15803D)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              f,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF374151)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Phải: Giá + Nút
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      package.formattedPrice,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: themeColor,
                      ),
                    ),
                    if (package.originalPrice != null) ...[
                      Text(
                        package.formattedOriginalPrice,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => PaymentMethodBottomSheet(package: package),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(80, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text(
                    'Nâng cấp',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}