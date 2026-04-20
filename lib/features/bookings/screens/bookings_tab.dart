import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../../home/providers/home_provider.dart';
import '../../home/data/models/home_models.dart';

class BookingsTab extends StatelessWidget {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_, provider, __) {
        return Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            GradientContainer(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Workouts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded,
                            color: Colors.white70),
                        onPressed: () => provider.loadAll(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.status == HomeStatus.error
                      ? _ErrorView(
                          message: provider.error,
                          onRetry: provider.loadAll,
                        )
                      : _ContentView(
                          memberships: provider.activeMemberships,
                          services: provider.serviceRegistrations,
                        ),
            ),
          ],
        );
      },
    );
  }
}

// ── Content ────────────────────────────────────────────────────────────────
class _ContentView extends StatelessWidget {
  final List<ActiveMembershipItem> memberships;
  final List<ServiceRegistrationItem> services;

  const _ContentView({
    required this.memberships,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    if (memberships.isEmpty && services.isEmpty) {
      return const _EmptyView();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Goi tap ──────────────────────────────────────────────
        if (memberships.isNotEmpty) ...[
          _SectionLabel(
            icon: Icons.card_membership_rounded,
            label: 'Registered Memberships (${memberships.length})',
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(height: 10),
          ...memberships.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MembershipScheduleCard(item: m),
              )),
          const SizedBox(height: 20),
        ],

        // ── Dich vu ──────────────────────────────────────────────
        if (services.isNotEmpty) ...[
          _SectionLabel(
            icon: Icons.fitness_center_rounded,
            label: 'Registered Services (${services.length})',
            color: const Color(0xFF01B3CA),
          ),
          const SizedBox(height: 10),
          ...services.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ServiceScheduleCard(item: s),
              )),
        ],
      ],
    );
  }
}

// ── Membership Schedule Card ───────────────────────────────────────────────
class _MembershipScheduleCard extends StatelessWidget {
  final ActiveMembershipItem item;
  const _MembershipScheduleCard({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case 'ACTIVE': return const Color(0xFF10B981);
      case 'EXPIRED': return const Color(0xFF6B7280);
      case 'CANCELLED': return const Color(0xFFEF4444);
      default: return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCalendar(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.card_membership_rounded,
                  color: AppTheme.primaryBlue, size: 24),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.packageName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${item.formatDate(item.startDate)} - ${item.formatDate(item.endDate)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Remaining: ${item.remainingDays} days',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.statusLabel,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _statusColor),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(Icons.calendar_month_rounded,
                    color: AppTheme.primaryBlue, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCalendar(BuildContext context) {
    DateTime? start;
    DateTime? end;
    try {
      start = DateTime.parse(item.startDate);
      end = DateTime.parse(item.endDate);
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CalendarSheet(
        title: item.packageName,
        subtitle: 'Membership - ${item.statusLabel}',
        startDate: start,
        endDate: end,
        color: AppTheme.primaryBlue,
        icon: Icons.card_membership_rounded,
        details: [
          _DetailRow(label: 'Start', value: item.formatDate(item.startDate)),
          _DetailRow(label: 'End', value: item.formatDate(item.endDate)),
          _DetailRow(label: 'Remaining', value: '${item.remainingDays} days'),
          _DetailRow(label: 'Value', value: item.formattedPrice),
          _DetailRow(label: 'Duration', value: '${item.duration} days'),
        ],
      ),
    );
  }
}

// ── Service Schedule Card ──────────────────────────────────────────────────
class _ServiceScheduleCard extends StatelessWidget {
  final ServiceRegistrationItem item;
  const _ServiceScheduleCard({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case 'ACTIVE':
        if (item.bookingStatus == 'REJECTED' ||
            item.bookingStatus == 'CANCELLED') return const Color(0xFFEF4444);
        return const Color(0xFF10B981);
      case 'CONFIRMED': return AppTheme.primaryBlue;
      case 'PENDING': return const Color(0xFFF59E0B);
      case 'EXPIRED': return const Color(0xFF6B7280);
      case 'CANCELLED': return const Color(0xFFEF4444);
      case 'COMPLETED': return const Color(0xFF6B7280);
      default: return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCalendar(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF01B3CA).withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF01B3CA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.fitness_center_rounded,
                  color: Color(0xFF01B3CA), size: 24),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.serviceName ?? 'Service',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (item.trainerName != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          item.trainerName!,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${item.formatDate(item.startDate)} - ${item.formatDate(item.endDate)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.statusLabel,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _statusColor),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.calendar_month_rounded,
                    color: Color(0xFF01B3CA), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCalendar(BuildContext context) {
    DateTime? start;
    DateTime? end;
    try {
      if (item.startDate != null) start = DateTime.parse(item.startDate!);
      if (item.endDate != null) end = DateTime.parse(item.endDate!);
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CalendarSheet(
        title: item.serviceName ?? 'Dich vu',
        subtitle: item.trainerName != null
            ? 'Trainer: ${item.trainerName}'
            : 'Service - ${item.statusLabel}',
        startDate: start,
        endDate: end,
        color: const Color(0xFF01B3CA),
        icon: Icons.fitness_center_rounded,
        details: [
          _DetailRow(
              label: 'Start', value: item.formatDate(item.startDate)),
          _DetailRow(
              label: 'End', value: item.formatDate(item.endDate)),
          if (item.trainerName != null)
            _DetailRow(label: 'Trainer', value: item.trainerName!),
          if (item.formattedPrice.isNotEmpty)
            _DetailRow(label: 'Price', value: item.formattedPrice),
          if (item.duration != null)
            _DetailRow(
                label: 'Duration', value: '${item.duration} min/session'),
        ],
      ),
    );
  }
}

// ── Calendar Bottom Sheet ──────────────────────────────────────────────────
class _CalendarSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final DateTime? startDate;
  final DateTime? endDate;
  final Color color;
  final IconData icon;
  final List<_DetailRow> details;

  const _CalendarSheet({
    required this.title,
    required this.subtitle,
    required this.startDate,
    required this.endDate,
    required this.color,
    required this.icon,
    required this.details,
  });

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _displayMonth = widget.startDate ?? DateTime.now();
    // Normalize to first of month
    _displayMonth = DateTime(_displayMonth.year, _displayMonth.month, 1);
  }

  bool _isInRange(DateTime day) {
    if (widget.startDate == null || widget.endDate == null) return false;
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(
        widget.startDate!.year, widget.startDate!.month, widget.startDate!.day);
    final e = DateTime(
        widget.endDate!.year, widget.endDate!.month, widget.endDate!.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  bool _isStart(DateTime day) {
    if (widget.startDate == null) return false;
    return day.year == widget.startDate!.year &&
        day.month == widget.startDate!.month &&
        day.day == widget.startDate!.day;
  }

  bool _isEnd(DateTime day) {
    if (widget.endDate == null) return false;
    return day.year == widget.endDate!.year &&
        day.month == widget.endDate!.month &&
        day.day == widget.endDate!.day;
  }

  void _prevMonth() {
    setState(() {
      _displayMonth =
          DateTime(_displayMonth.year, _displayMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayMonth =
          DateTime(_displayMonth.year, _displayMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateUtils.getDaysInMonth(_displayMonth.year, _displayMonth.month);
    final firstWeekday =
        DateTime(_displayMonth.year, _displayMonth.month, 1).weekday; // 1=Mon
    final totalCells = firstWeekday - 1 + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
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
            const Divider(height: 24),
            // Calendar
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  children: [
                    // Month navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _prevMonth,
                        ),
                        Text(
                          _monthLabel(_displayMonth),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Day labels
                    Row(
                      children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                          .map((d) => Expanded(
                                child: Center(
                                  child: Text(
                                    d,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    // Calendar grid
                    ...List.generate(rows, (row) {
                      return Row(
                        children: List.generate(7, (col) {
                          final cellIndex = row * 7 + col;
                          final dayNum =
                              cellIndex - (firstWeekday - 1) + 1;
                          if (dayNum < 1 || dayNum > daysInMonth) {
                            return const Expanded(child: SizedBox(height: 44));
                          }
                          final day = DateTime(
                              _displayMonth.year, _displayMonth.month, dayNum);
                          final inRange = _isInRange(day);
                          final isStart = _isStart(day);
                          final isEnd = _isEnd(day);
                          final isToday = _isSameDay(day, DateTime.now());

                          return Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: inRange
                                    ? widget.color.withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.horizontal(
                                  left: isStart
                                      ? const Radius.circular(22)
                                      : Radius.zero,
                                  right: isEnd
                                      ? const Radius.circular(22)
                                      : Radius.zero,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: (isStart || isEnd)
                                        ? widget.color
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: isToday && !isStart && !isEnd
                                        ? Border.all(
                                            color: widget.color, width: 1.5)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$dayNum',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: (isStart || isEnd)
                                            ? FontWeight.w800
                                            : inRange
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                        color: (isStart || isEnd)
                                            ? Colors.white
                                            : inRange
                                                ? widget.color
                                                : AppTheme.textPrimary,
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
                    const SizedBox(height: 8),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendDot(color: widget.color, label: 'Active period'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: widget.details
                            .map((d) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        d.label,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textSecondary),
                                      ),
                                      Text(
                                        d.value,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────
class _DetailRow {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ],
      );
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📅', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'No services or memberships yet',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Register to view your schedule here',
              style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary.withOpacity(0.8)),
            ),
          ],
        ),
      );
}

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
                  onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
}
