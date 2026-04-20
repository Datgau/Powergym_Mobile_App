import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import 'package:powergym_mobile_app/core/network/api.dart';
import '../../../auth/providers/auth_provider.dart';

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({super.key});

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<ScheduleTab> {
  Future<List<_TeachingItem>>? _future;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  void _load() {
    if (!mounted) return;
    setState(() {
      _future = _fetchSchedule();
    });
  }

  Future<List<_TeachingItem>> _fetchSchedule() async {
    final res = await Api.private.get('/service-registrations/my-clients');
    final rawList = (res.data as Map<String, dynamic>)['data'];
    final list = rawList is List
        ? rawList.cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];

    return list.map((reg) {
      final svc = reg['gymService'] as Map<String, dynamic>?
          ?? reg['service'] as Map<String, dynamic>?;
      final user = reg['user'] as Map<String, dynamic>?;

      // Latest booking date from upcomingBookings
      String? bookingDate;
      final bookings = reg['upcomingBookings'] as List?;
      if (bookings != null && bookings.isNotEmpty) {
        bookingDate =
            (bookings.first as Map<String, dynamic>)['bookingDate'] as String?;
      }

      return _TeachingItem(
        memberName: reg['userName'] as String?
            ?? user?['fullName'] as String?
            ?? 'Student',
        memberAvatar: reg['userAvatar'] as String?
            ?? user?['avatar'] as String?,
        serviceName: reg['serviceName'] as String?
            ?? svc?['name'] as String?
            ?? 'Service',
        startDate: reg['registrationDate'] as String?,
        endDate: reg['expirationDate'] as String?
            ?? reg['endDate'] as String?,
        bookingDate: bookingDate,
      );
    }).toList()
      ..sort((a, b) {
        // Sort by booking date, then end date
        final aDate = a.bookingDate ?? a.endDate ?? '';
        final bDate = b.bookingDate ?? b.endDate ?? '';
        return aDate.compareTo(bDate);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────
        GradientContainer(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Teaching Schedule',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800)),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: Colors.white70),
                    onPressed: _load,
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Content ──────────────────────────────────────────────────
        Expanded(
          child: FutureBuilder<List<_TeachingItem>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.error, size: 40),
                      const SizedBox(height: 8),
                      const Text('Could not load schedule'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                );
              }
              final items = snap.data ?? [];
              if (items.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📅', style: TextStyle(fontSize: 48)),
                      SizedBox(height: 12),
                      Text('No teaching sessions yet',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _TeachingCard(item: items[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Data model ─────────────────────────────────────────────────────
class _TeachingItem {
  final String memberName;
  final String? memberAvatar;
  final String serviceName;
  final String? startDate;
  final String? endDate;
  final String? bookingDate;

  const _TeachingItem({
    required this.memberName,
    this.memberAvatar,
    required this.serviceName,
    this.startDate,
    this.endDate,
    this.bookingDate,
  });

  String _fmt(String? s) {
    if (s == null || s.isEmpty) return '—';
    try {
      // Handle both date formats: "2026-06-18" or "2026-06-18T16:41:13.456916"
      final dateStr = s;
      final DateTime d;
      if (dateStr.contains('T')) {
        // Full datetime format - extract date part only
        d = DateTime.parse(dateStr);
      } else {
        // Date only format
        d = DateTime.parse(dateStr);
      }
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (e) {
      print('Error formatting date: $s, error: $e');
      return s;
    }
  }

  String get fmtStart => _fmt(startDate);
  String get fmtEnd => _fmt(endDate);
  String get fmtBooking => _fmt(bookingDate);
}

// ── Teaching card ──────────────────────────────────────────────────
class _TeachingCard extends StatelessWidget {
  final _TeachingItem item;
  const _TeachingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _CalendarSheet(item: item),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8EEF5)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                shape: BoxShape.circle,
              ),
              child: item.memberAvatar != null
                  ? ClipOval(
                      child: Image.network(
                        item.memberAvatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _AvatarFallback(name: item.memberName),
                      ),
                    )
                  : _AvatarFallback(name: item.memberName),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.memberName,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 2),
                  Text(item.serviceName,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _InfoRow(
                          icon: Icons.play_circle_outline,
                          label: item.fmtStart,
                          color: const Color(0xFF10B981)),
                      _InfoRow(
                          icon: Icons.stop_circle_outlined,
                          label: item.fmtEnd,
                          color: const Color(0xFFEF4444)),
                      if (item.bookingDate != null)
                        _InfoRow(
                            icon: Icons.event_rounded,
                            label: 'Appt: ${item.fmtBooking}',
                            color: AppTheme.primaryBlue),
                    ],
                  ),
                ],
              ),
            ),
            // Calendar icon hint
            const Icon(Icons.calendar_month_rounded,
                color: AppTheme.primaryBlue, size: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoRow(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: color)),
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800),
      ),
    );
  }
}

// ── Calendar bottom sheet ──────────────────────────────────────────
class _CalendarSheet extends StatefulWidget {
  final _TeachingItem item;
  const _CalendarSheet({required this.item});

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    // Start from today's month
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month, 1);
  }

  // Highlight from today to service end date
  DateTime get _rangeStart => DateTime.now();
  DateTime? get _rangeEnd {
    try {
      if (widget.item.endDate == null || widget.item.endDate!.isEmpty) return null;
      // Handle both date formats: "2026-06-18" or "2026-06-18T16:41:13.456916"
      final dateStr = widget.item.endDate!;
      final DateTime parsed;
      if (dateStr.contains('T')) {
        // Full datetime format
        parsed = DateTime.parse(dateStr);
      } else {
        // Date only format
        parsed = DateTime.parse(dateStr);
      }
      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (e) {
      print('Error parsing endDate: ${widget.item.endDate}, error: $e');
      return null;
    }
  }

  bool _isInRange(DateTime day) {
    final end = _rangeEnd;
    if (end == null) return false;
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(
        _rangeStart.year, _rangeStart.month, _rangeStart.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }

  bool _isEnd(DateTime day) {
    final end = _rangeEnd;
    if (end == null) return false;
    return day.year == end.year &&
        day.month == end.month &&
        day.day == end.day;
  }

  bool _isBookingDate(DateTime day) {
    try {
      if (widget.item.bookingDate == null) return false;
      final bd = DateTime.parse(widget.item.bookingDate!);
      return day.year == bd.year &&
          day.month == bd.month &&
          day.day == bd.day;
    } catch (_) {
      return false;
    }
  }

  void _prevMonth() => setState(() =>
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1));
  void _nextMonth() => setState(() =>
      _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1));

  String _monthLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateUtils.getDaysInMonth(_displayMonth.year, _displayMonth.month);
    final firstWeekday =
        DateTime(_displayMonth.year, _displayMonth.month, 1).weekday;
    final rows = ((firstWeekday - 1 + daysInMonth) / 7).ceil();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
                  borderRadius: BorderRadius.circular(2)),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      shape: BoxShape.circle,
                    ),
                    child: widget.item.memberAvatar != null
                        ? ClipOval(
                            child: Image.network(
                              widget.item.memberAvatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _AvatarFallback(name: widget.item.memberName),
                            ),
                          )
                        : _AvatarFallback(name: widget.item.memberName),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.item.memberName,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary)),
                        Text(widget.item.serviceName,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),
            // Calendar
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    // Month nav
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _prevMonth),
                        Text(_monthLabel(_displayMonth),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary)),
                        IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _nextMonth),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Day labels
                    Row(
                      children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                          .map((d) => Expanded(
                                child: Center(
                                  child: Text(d,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary)),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    // Grid
                    ...List.generate(rows, (row) {
                      return Row(
                        children: List.generate(7, (col) {
                          final cellIndex = row * 7 + col;
                          final dayNum = cellIndex - (firstWeekday - 1) + 1;
                          if (dayNum < 1 || dayNum > daysInMonth) {
                            return const Expanded(
                                child: SizedBox(height: 44));
                          }
                          final day = DateTime(_displayMonth.year,
                              _displayMonth.month, dayNum);
                          final inRange = _isInRange(day);
                          final isEnd = _isEnd(day);
                          final isToday = _isToday(day);
                          final isAppt = _isBookingDate(day);

                          // Colors
                          Color? bgColor;
                          Color textColor = AppTheme.textPrimary;
                          Color? circleColor;

                          if (isEnd) {
                            circleColor = const Color(0xFFEF4444);
                            textColor = Colors.white;
                          } else if (isAppt) {
                            circleColor = AppTheme.primaryBlue;
                            textColor = Colors.white;
                          } else if (isToday && inRange) {
                            circleColor = const Color(0xFF10B981);
                            textColor = Colors.white;
                          } else if (inRange) {
                            bgColor = AppTheme.primaryBlue.withOpacity(0.12);
                            textColor = AppTheme.primaryBlue;
                          }

                          return Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.horizontal(
                                  left: (col == 0 || dayNum == 1)
                                      ? const Radius.circular(22)
                                      : Radius.zero,
                                  right: (col == 6 || dayNum == daysInMonth)
                                      ? const Radius.circular(22)
                                      : Radius.zero,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: circleColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$dayNum',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: circleColor != null
                                            ? FontWeight.w800
                                            : inRange
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                    const SizedBox(height: 16),
                    // Legend
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _Legend(
                            color: const Color(0xFF10B981), label: 'Today'),
                        _Legend(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            label: 'Active period'),
                        _Legend(
                            color: AppTheme.primaryBlue,
                            label: 'Appointment'),
                        _Legend(
                            color: const Color(0xFFEF4444),
                            label: 'End date'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _DetailRow(
                              label: 'Start',
                              value: widget.item.fmtStart),
                          _DetailRow(
                              label: 'End', value: widget.item.fmtEnd),
                          if (widget.item.bookingDate != null)
                            _DetailRow(
                                label: 'Appointment',
                                value: widget.item.fmtBooking),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}
