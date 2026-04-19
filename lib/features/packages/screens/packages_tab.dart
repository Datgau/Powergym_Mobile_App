import 'package:flutter/material.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import '../models/membership_package.dart';
import '../services/packages_service.dart';
import '../widgets/payment_method_bottom_sheet.dart';

Color _parseColor(String? hex) {
  if (hex == null || hex.isEmpty) return AppTheme.primaryBlue;
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return AppTheme.primaryBlue;
  }
}

class PackagesTab extends StatefulWidget {
  final VoidCallback? onPaymentSuccess;
  const PackagesTab({super.key, this.onPaymentSuccess});

  @override
  State<PackagesTab> createState() => _PackagesTabState();
}

class _PackagesTabState extends State<PackagesTab> {
  final PackagesService _svc = PackagesService();
  late Future<List<MembershipPackage>> _packagesFuture;
  Set<int> _activeIds = {};
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _packagesFuture = _svc.getAvailablePackages();
    _loadActiveIds();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadActiveIds() async {
    final ids = await _svc.getActivePackageIds();
    if (mounted) setState(() => _activeIds = ids);
  }

  void _onPaymentSuccess() {
    _loadActiveIds();
    widget.onPaymentSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Thanh tìm kiếm ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(fontSize: 13),
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Tìm gói tập...',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => _searchCtrl.clear(),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.primaryBlue),
              ),
            ),
          ),
        ),

        // ── Danh sách ───────────────────────────────────────────────────
        Expanded(
          child: FutureBuilder<List<MembershipPackage>>(
            future: _packagesFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Text('Lỗi: ${snap.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 13)),
                );
              }
              final all = snap.data ?? [];
              final packages = _query.isEmpty
                  ? all
                  : all.where((p) =>
                      p.name.toLowerCase().contains(_query) ||
                      (p.description?.toLowerCase().contains(_query) ?? false)).toList();

              if (all.isEmpty) {
                return const Center(
                    child: Text('Hiện không có gói tập nào.',
                        style: TextStyle(fontSize: 13)));
              }
              if (packages.isEmpty) {
                return Center(
                  child: Text('Không tìm thấy "$_query"',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                itemCount: packages.length,
                itemBuilder: (_, i) {
                  final pkg = packages[i];
                  final registered = _activeIds.contains(pkg.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: pkg.price > 5000000
                        ? _PlanCardWide(
                            package: pkg,
                            isRegistered: registered,
                            onPaymentSuccess: _onPaymentSuccess,
                          )
                        : _PlanCard(
                            package: pkg,
                            isRegistered: registered,
                            onPaymentSuccess: _onPaymentSuccess,
                          ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Card Gói Thường (nhỏ gọn) ────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final MembershipPackage package;
  final bool isRegistered;
  final VoidCallback? onPaymentSuccess;

  const _PlanCard({required this.package, required this.isRegistered, this.onPaymentSuccess});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(package.color);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isRegistered ? const Color(0xFF15803D) : package.isPopular ? color : const Color(0xFFE8EEF5),
              width: isRegistered || package.isPopular ? 2 : 1,
            ),
          ),
          child: Opacity(
            opacity: isRegistered ? 0.75 : 1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (package.isPopular || isRegistered) const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('💎', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(package.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A202C))),
                          Text(package.durationText,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(package.formattedPrice,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
                        if (package.originalPrice != null)
                          Text(package.formattedOriginalPrice,
                              style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...package.features.take(3).map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(3)),
                          child: const Center(child: Text('✓', style: TextStyle(fontSize: 8, color: Color(0xFF15803D), fontWeight: FontWeight.w700))),
                        ),
                        const SizedBox(width: 6),
                        Flexible(child: Text(f, style: const TextStyle(fontSize: 11, color: Color(0xFF374151)))),
                      ]),
                    )),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton(
                    onPressed: isRegistered
                        ? null
                        : () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => PaymentMethodBottomSheet(package: package, onPaymentSuccess: onPaymentSuccess),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRegistered ? const Color(0xFFDCFCE7) : package.isPopular ? color : const Color(0xFFE8F0FE),
                      foregroundColor: isRegistered ? const Color(0xFF15803D) : package.isPopular ? Colors.white : AppTheme.primaryBlue,
                      disabledBackgroundColor: const Color(0xFFDCFCE7),
                      disabledForegroundColor: const Color(0xFF15803D),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isRegistered) ...[const Icon(Icons.check_circle, size: 13), const SizedBox(width: 4)],
                        Text(isRegistered ? 'Đã đăng ký' : 'Mua ngay'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0, right: 0,
          child: isRegistered
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF15803D),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomLeft: Radius.circular(8)),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 10),
                    SizedBox(width: 3),
                    Text('ĐÃ ĐĂNG KÝ', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                  ]),
                )
              : package.isPopular
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomLeft: Radius.circular(8)),
                      ),
                      child: const Text('PHỔ BIẾN', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                    )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ── Card Gói VIP (nhỏ gọn) ───────────────────────────────────────────────────
class _PlanCardWide extends StatelessWidget {
  final MembershipPackage package;
  final bool isRegistered;
  final VoidCallback? onPaymentSuccess;

  const _PlanCardWide({required this.package, required this.isRegistered, this.onPaymentSuccess});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(package.color);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isRegistered ? const Color(0xFF15803D) : const Color(0xFFE8EEF5),
          width: isRegistered ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Opacity(
        opacity: isRegistered ? 0.75 : 1.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trái
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5, runSpacing: 3,
                    children: [
                      const Text('👑', style: TextStyle(fontSize: 16)),
                      Text(package.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A202C))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: const Color(0xFF1A202C), borderRadius: BorderRadius.circular(4)),
                        child: const Text('VIP', style: TextStyle(color: Color(0xFFFFD700), fontSize: 8, fontWeight: FontWeight.w800)),
                      ),
                      if (isRegistered)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFF15803D), borderRadius: BorderRadius.circular(4)),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 9),
                            SizedBox(width: 2),
                            Text('ĐÃ ĐĂNG KÝ', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w800)),
                          ]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(package.durationText, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                  const SizedBox(height: 6),
                  ...package.features.take(2).map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(children: [
                          const Icon(Icons.check_circle, size: 11, color: Color(0xFF15803D)),
                          const SizedBox(width: 4),
                          Expanded(child: Text(f, style: const TextStyle(fontSize: 10, color: Color(0xFF374151)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]),
                      )),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Phải
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(package.formattedPrice,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
                if (package.originalPrice != null)
                  Text(package.formattedOriginalPrice,
                      style: const TextStyle(fontSize: 9, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    onPressed: isRegistered
                        ? null
                        : () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => PaymentMethodBottomSheet(package: package, onPaymentSuccess: onPaymentSuccess),
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRegistered ? const Color(0xFFDCFCE7) : color,
                      foregroundColor: isRegistered ? const Color(0xFF15803D) : Colors.white,
                      disabledBackgroundColor: const Color(0xFFDCFCE7),
                      disabledForegroundColor: const Color(0xFF15803D),
                      elevation: 0,
                      minimumSize: const Size(70, 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    child: Text(isRegistered ? 'Đã đăng ký' : 'Nâng cấp'),
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
