import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';

class BookingsTab extends StatelessWidget {
  const BookingsTab({super.key});
  
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Hero App Bar ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: GradientContainer(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: greeting + notification bell
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Chào buổi sáng,',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Nguyễn Văn A 👋',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFD700),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Membership badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      child: const Text(
                        '★  GOLD MEMBER',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats row
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: const [
                          _StatItem(value: '12', label: 'Buổi tập'),
                          _StatDivider(),
                          _StatItem(value: '8', label: 'Tuần streak'),
                          _StatDivider(),
                          _StatItem(value: '24', label: 'Ngày còn lại'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Body ─────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFFF5F7FB),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Actions (4 items)
                const _SectionHeader(title: 'Thao tác nhanh'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QuickActionItem(
                      icon: Icons.calendar_month,
                      label: 'Đặt lịch',
                      bgColor: const Color(0xFFE8F0FE),
                      iconColor: AppTheme.primaryBlue,
                      onTap: () {},
                    ),
                    _QuickActionItem(
                      icon: Icons.fitness_center,
                      label: 'Bài tập',
                      bgColor: const Color(0xFFFCE8E8),
                      iconColor: Colors.redAccent,
                      onTap: () {},
                    ),
                    _QuickActionItem(
                      icon: Icons.restaurant_menu,
                      label: 'Dinh dưỡng',
                      bgColor: const Color(0xFFE8FCE8),
                      iconColor: Colors.green,
                      onTap: () {},
                    ),
                    _QuickActionItem(
                      icon: Icons.bar_chart,
                      label: 'Thống kê',
                      bgColor: const Color(0xFFFEF5E8),
                      iconColor: Colors.orange,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // AI Trainer Banner
                _AITrainerBanner(),
                const SizedBox(height: 20),

                // Upcoming Bookings
                _SectionHeader(
                  title: 'Lịch tập sắp tới',
                  actionLabel: 'Xem tất cả',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                const _BookingCard(
                  trainerName: 'PT. Nguyễn Văn B',
                  specialty: 'Gym & Strength',
                  date: '15/04/2026',
                  time: '09:00 – 10:00',
                  status: '✓  Đã xác nhận',
                  statusColor: AppTheme.success,
                  avatarEmoji: '💪',
                ),
                const SizedBox(height: 10),
                const _BookingCard(
                  trainerName: 'PT. Trần Thị C',
                  specialty: 'Yoga & Flexibility',
                  date: '17/04/2026',
                  time: '14:00 – 15:00',
                  status: '⏳  Chờ xác nhận',
                  statusColor: AppTheme.warning,
                  avatarEmoji: '🧘',
                ),
                const SizedBox(height: 20),

                // Weekly Progress
                _SectionHeader(
                  title: 'Tiến độ tuần này',
                  actionLabel: 'Chi tiết',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                const _WeeklyProgressCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Stat item in hero ──────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

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
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: Colors.white12);
  }
}

// ── Quick action item ──────────────────────────────────────────────
class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EEF5)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── AI Trainer Banner ─────────────────────────────────────────────
class _AITrainerBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PT AI tư vấn ngay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Lên kế hoạch tập luyện cá nhân hóa cho bạn',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
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
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 0,
            ),
            child: const Text(
              'Thử ngay',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

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

// ── Booking Card ──────────────────────────────────────────────────
class _BookingCard extends StatefulWidget {
  final TrainerBooking booking;
  final VoidCallback onRefresh; // Thêm callback để load lại danh sách khi hủy thành công

  const _BookingCard({required this.booking, required this.onRefresh});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _isCancelling = false;

  // Chuyển đổi trạng thái thành màu sắc
  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING': return Colors.orange;
      case 'CONFIRMED': return Colors.green;
      case 'CANCELLED': case 'REJECTED': return Colors.red;
      case 'COMPLETED': return Colors.blue;
      default: return Colors.grey;
    }
  }

  // Định dạng lại ngày giờ
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Logic hiển thị Popup xác nhận hủy
  Future<void> _showCancelDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn PT này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hủy lịch', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _cancelBooking();
    }
  }

  // Gọi API Hủy lịch
  Future<void> _cancelBooking() async {
    setState(() => _isCancelling = true);
    try {
      final storage = StorageService();
      final userId = await storage.getUserId();
      if (userId == null) throw Exception("Lỗi: Không tìm thấy User ID");

      final success = await BookingsService().cancelBooking(widget.booking.id.toString(), userId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã hủy lịch thành công!'), backgroundColor: Colors.green),
        );
        widget.onRefresh(); // Gọi hàm load lại danh sách của thẻ cha
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.booking.status);
    final trainerName = widget.booking.trainer?.fullName ?? 'Đang chờ Admin xếp PT';
    final serviceName = widget.booking.service?.name ?? 'Dịch vụ Gym';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar giả lập
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainerName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A202C)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      serviceName,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text(_formatDate(widget.booking.bookingDate), style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, size: 14, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text('${widget.booking.startTime.substring(0,5)} - ${widget.booking.endTime.substring(0,5)}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.booking.statusText,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // ── NÚT HỦY LỊCH (Chỉ hiện khi trạng thái là PENDING) ──
          if (widget.booking.status == 'PENDING') ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: _isCancelling 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : TextButton.icon(
                    onPressed: () => _showCancelDialog(context),
                    icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                    label: const Text('Hủy lịch', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
            )
          ]
        ],
      ),
    );
  }
}

// ── Weekly Progress Card ──────────────────────────────────────────
class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Column(
        children: const [
          _ProgressRow(label: 'Cardio', value: 0.75),
          SizedBox(height: 12),
          _ProgressRow(label: 'Sức mạnh', value: 0.60),
          SizedBox(height: 12),
          _ProgressRow(label: 'Linh hoạt', value: 0.90),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;
  const _ProgressRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: const Color(0xFFE8EEF5),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(value * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A202C),
          ),
        ),
      ],
    );
  }
}
