import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/schedule_model.dart';
import '../providers/schedule_provider.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = context.read<AuthProvider>().currentUser?.id.toString() ?? '';
      context.read<ScheduleProvider>().load(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();

    return Column(
      children: [
        // ── Header + week strip ──────────────────────────────────────
        GradientContainer(
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
                      const Text('Lịch tập',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800)),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded,
                            color: Colors.white70),
                        onPressed: () {
                          final id = context
                              .read<AuthProvider>()
                              .currentUser
                              ?.id
                              .toString() ?? '';
                          context.read<ScheduleProvider>().load(id);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _WeekStrip(
                    selectedDate: provider.selectedDate,
                    datesWithBookings: provider.datesWithBookings,
                    onSelect: provider.selectDate,
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Day bookings ─────────────────────────────────────────────
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.status == ScheduleStatus.error
                  ? _ErrorView(
                      message: provider.error,
                      onRetry: () {
                        final id = context
                            .read<AuthProvider>()
                            .currentUser
                            ?.id
                            .toString() ?? '';
                        context.read<ScheduleProvider>().load(id);
                      },
                    )
                  : _DayView(
                      bookings: provider.bookingsForSelectedDate,
                      selectedDate: provider.selectedDate,
                      onAccept: (bookingId) =>
                          context.read<ScheduleProvider>().acceptBooking(bookingId),
                    ),
        ),
      ],
    );
  }
}

// ── Week strip ────────────────────────────────────────────────────────────────
class _WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Set<String> datesWithBookings;
  final void Function(DateTime) onSelect;

  const _WeekStrip({
    required this.selectedDate,
    required this.datesWithBookings,
    required this.onSelect,
  });

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Row(
      children: List.generate(7, (i) {
        final day = days[i];
        final isSelected = _dateKey(day) == _dateKey(selectedDate);
        final isToday = _dateKey(day) == _dateKey(now);
        final hasBooking = datesWithBookings.contains(_dateKey(day));

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(day),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(labels[i],
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : Colors.white70)),
                  const SizedBox(height: 4),
                  Text('${day.day}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : isToday
                                  ? const Color(0xFFFFD700)
                                  : Colors.white)),
                  const SizedBox(height: 4),
                  // Dot indicator nếu có booking
                  Container(
                    width: 5, height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasBooking
                          ? (isSelected ? AppTheme.primaryBlue : Colors.white)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Day view ──────────────────────────────────────────────────────────────────
class _DayView extends StatelessWidget {
  final List<DayBooking> bookings;
  final DateTime selectedDate;
  final void Function(String bookingId) onAccept;

  const _DayView({
    required this.bookings,
    required this.selectedDate,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📅', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Không có lịch hẹn ngày ${selectedDate.day}/${selectedDate.month}',
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final pending   = bookings.where((b) => b.isPending).toList();
    final confirmed = bookings.where((b) => !b.isPending).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Yêu cầu chờ xác nhận ──────────────────────────────────
        if (pending.isNotEmpty) ...[
          _SectionLabel(
            icon: Icons.hourglass_top_rounded,
            label: 'Chờ xác nhận (${pending.length})',
            color: AppTheme.warning,
          ),
          const SizedBox(height: 8),
          ...pending.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BookingSlotCard(
                    booking: b, onAccept: () => onAccept(b.bookingId)),
              )),
          const SizedBox(height: 16),
        ],

        // ── Lịch đã xác nhận / hoàn thành ─────────────────────────
        if (confirmed.isNotEmpty) ...[
          _SectionLabel(
            icon: Icons.check_circle_rounded,
            label: 'Đã xác nhận (${confirmed.length})',
            color: AppTheme.success,
          ),
          const SizedBox(height: 8),
          ...confirmed.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BookingSlotCard(booking: b, onAccept: () {}),
              )),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      );
}

// ── Booking slot card ─────────────────────────────────────────────────────────
class _BookingSlotCard extends StatelessWidget {
  final DayBooking booking;
  final VoidCallback onAccept;

  const _BookingSlotCard({required this.booking, required this.onAccept});

  Color get _statusColor {
    if (booking.isPending)   return AppTheme.warning;
    if (booking.isConfirmed) return AppTheme.success;
    if (booking.isCompleted) return AppTheme.primaryBlue;
    return AppTheme.textSecondary;
  }

  IconData get _statusIcon {
    if (booking.isPending)   return Icons.hourglass_top_rounded;
    if (booking.isConfirmed) return Icons.check_circle_rounded;
    if (booking.isCompleted) return Icons.done_all_rounded;
    return Icons.cancel_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _statusColor.withOpacity(booking.isPending ? 0.4 : 0.2),
          width: booking.isPending ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time + status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, size: 14, color: _statusColor),
                      const SizedBox(width: 5),
                      Text(
                        '${booking.startTime} – ${booking.endTime}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: _statusColor),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Member info
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: AppTheme.brandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: booking.memberAvatar != null
                      ? ClipOval(
                          child: Image.network(booking.memberAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _avatarFallback()),
                        )
                      : _avatarFallback(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.memberName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      if (booking.serviceName != null)
                        Text(booking.serviceName!,
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),

            // Nút xác nhận nếu PENDING
            if (booking.isPending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Xác nhận lịch hẹn'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback() => Center(
        child: Text(
          booking.memberName.isNotEmpty
              ? booking.memberName[0].toUpperCase()
              : '?',
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
        ),
      );
}

// ── Error view ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 40),
              const SizedBox(height: 8),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: onRetry, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
}
