import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../models/gym_service_model.dart';
import '../services/gym_service_api.dart';
import 'service_booking_flow.dart';

class ServicesTab extends StatefulWidget {
  const ServicesTab({super.key});

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  final GymServiceApi _api = GymServiceApi();
  late Future<List<GymService>> _future;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _api.getActiveServices();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
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
              hintText: 'Search services...',
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
          child: FutureBuilder<List<GymService>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorView(
                  message: 'Could not load services',
                  onRetry: () => setState(() => _future = _api.getActiveServices()),
                );
              }
              final all = snapshot.data ?? [];
              final services = _query.isEmpty
                  ? all
                  : all.where((s) =>
                      s.name.toLowerCase().contains(_query) ||
                      (s.category?.label.toLowerCase().contains(_query) ?? false) ||
                      (s.description?.toLowerCase().contains(_query) ?? false)).toList();

              if (all.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🏋️', style: TextStyle(fontSize: 36)),
                      SizedBox(height: 8),
                      Text('No services available',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                );
              }
              if (services.isEmpty) {
                return Center(
                  child: Text('No results for "$_query"',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                itemCount: services.length,
                itemBuilder: (_, i) => _ServiceCard(service: services[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Service Card (nhỏ gọn hơn) ───────────────────────────────────────────────
class _ServiceCard extends StatelessWidget {
  final GymService service;
  const _ServiceCard({required this.service});

  Color get _categoryColor {
    final hex = service.category?.color;
    if (hex == null || hex.isEmpty) return AppTheme.primaryBlue;
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor;
    final hasImage = service.images.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh nhỏ hơn
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: hasImage
                ? Image.network(service.images.first,
                    height: 110, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ImagePlaceholder(color: color, height: 110))
                : _ImagePlaceholder(color: color, height: 110),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category + tên
                Row(
                  children: [
                    if (service.category != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(service.category!.label,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(service.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1A202C)),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),

                // Mô tả
                if (service.description != null && service.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(service.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ],

                const SizedBox(height: 8),

                // Chips + nút cùng hàng
                Row(
                  children: [
                    _InfoChip(icon: Icons.attach_money_rounded, label: service.formattedPrice, color: color),
                    if (service.duration != null) ...[
                      const SizedBox(width: 6),
                      _InfoChip(icon: Icons.schedule_rounded, label: service.durationText, color: const Color(0xFF7C3AED)),
                    ],
                    const Spacer(),
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ServiceBookingFlow(service: service),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Register'),
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

class _ImagePlaceholder extends StatelessWidget {
  final Color color;
  final double height;
  const _ImagePlaceholder({required this.color, this.height = 110});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.6), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.fitness_center_rounded, color: Colors.white54, size: 36),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
