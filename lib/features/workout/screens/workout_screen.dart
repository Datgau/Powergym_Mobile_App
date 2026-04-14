import 'package:flutter/material.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/widgets/gradient_container.dart';
import '../models/user_membership.dart';
import '../models/user_service_registration.dart';
import '../services/workout_service.dart';

// ── Sealed union để biết item được chọn là loại nào ──────────────────────────
abstract class _WorkoutItem {
  String get title;
  String get subtitle;
  Color get color;
  Set<DateTime> get markedDays;
  DateTime get startDate;
  DateTime? get endDate;
  int get daysElapsed;
  int get duration;
  double get progressPercent;
  int get daysRemaining;
}

class _MembershipItem extends _WorkoutItem {
  final UserMembership m;
  _MembershipItem(this.m);

  @override String get title => m.packageName;
  @override String get subtitle => 'Gói tập • ${m.duration} ngày';
  @override Color get color {
    if (m.color == null || m.color!.isEmpty) return AppTheme.primaryBlue;
    try { return Color(int.parse('FF${m.color!.replaceAll('#', '')}', radix: 16)); }
    catch (_) { return AppTheme.primaryBlue; }
  }
  @override Set<DateTime> get markedDays => { for (final d in m.trainedDays) DateTime(d.year, d.month, d.day) };
  @override DateTime get startDate => m.startDate;
  @override DateTime? get endDate => m.endDate;
  @override int get daysElapsed => m.daysElapsed;
  @override int get duration => m.duration;
  @override double get progressPercent => m.progressPercent;
  @override int get daysRemaining => m.daysRemaining;
}

class _ServiceItem extends _WorkoutItem {
  final UserServiceRegistration sr;
  _ServiceItem(this.sr);

  @override String get title => sr.gymService.name;
  @override String get subtitle {
    final t = sr.trainer?.fullName;
    return t != null && t.isNotEmpty ? 'Dịch vụ • PT $t' : 'Dịch vụ • ${sr.gymService.duration} ngày';
  }
  @override Color get color => const Color(0xFF7C3AED);
  @override Set<DateTime> get markedDays => sr.bookedDays;
  @override DateTime get startDate => sr.registrationDate;
  @override DateTime? get endDate => sr.expirationDate;
  @override int get daysElapsed => sr.daysElapsed;
  @override int get duration => sr.duration;
  @override double get progressPercent => sr.progressPercent;
  @override int get daysRemaining => sr.daysRemaining;
}

// ── Main Screen ───────────────────────────────────────────────────────────────
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with SingleTickerProviderStateMixin {
  final WorkoutService _service = WorkoutService();
  late TabController _tabController;

  List<_WorkoutItem> _items = [];
  _WorkoutItem? _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _service.getActiveMemberships(),
        _service.getActiveServiceRegistrations(),
      ]);
      final memberships = (results[0] as List<UserMembership>)
          .map((m) => _MembershipItem(m) as _WorkoutItem)
          .toList();
      final services = (results[1] as List<UserServiceRegistration>)
          .map((sr) => _ServiceItem(sr) as _WorkoutItem)
          .toList();
      final all = [...memberships, ...services];
      setState(() {
        _items = all;
        _selected = all.isNotEmpty ? all.first : null;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          GradientContainer(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Text('Tập luyện',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded,
                              color: Colors.white70, size: 20),
                          onPressed: _load,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Đang hoạt động'),
                      Tab(text: 'Lịch tập'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _ErrorView(error: _error!, onRetry: _load)
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _OverviewTab(
                            items: _items,
                            selected: _selected,
                            onSelect: (item) {
                              setState(() => _selected = item);
                              _tabController.animateTo(1);
                            },
                          ),
                          _CalendarTab(selected: _selected),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final List<_WorkoutItem> items;
  final _WorkoutItem? selected;
  final void Function(_WorkoutItem) onSelect;

  const _OverviewTab(
      {required this.items, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🏋️', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('Chưa có gói tập hoặc dịch vụ nào đang hoạt động',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary)),
            SizedBox(height: 6),
            Text('Hãy mua gói tập hoặc đăng ký dịch vụ để bắt đầu!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    // Tách membership và service
    final memberships = items.whereType<_MembershipItem>().toList();
    final services = items.whereType<_ServiceItem>().toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (memberships.isNotEmpty) ...[
          _SectionLabel(
              icon: Icons.card_membership_rounded,
              label: 'Gói tập (${memberships.length})'),
          const SizedBox(height: 12),
          ...memberships.map((item) => _WorkoutCard(
                item: item,
                isSelected: selected == item,
                onTap: () => onSelect(item),
              )),
          const SizedBox(height: 8),
        ],
        if (services.isNotEmpty) ...[
          _SectionLabel(
              icon: Icons.fitness_center_rounded,
              label: 'Dịch vụ (${services.length})'),
          const SizedBox(height: 12),
          ...services.map((item) => _WorkoutCard(
                item: item,
                isSelected: selected == item,
                onTap: () => onSelect(item),
              )),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3)),
        ],
      );
}

class _WorkoutCard extends StatelessWidget {
  final _WorkoutItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _WorkoutCard(
      {required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = item.color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE8EEF5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item is _MembershipItem
                        ? Icons.card_membership_rounded
                        : Icons.fitness_center_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary)),
                      const SizedBox(height: 2),
                      Text(item.subtitle,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Đang hoạt động',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.success)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Dates
            Row(
              children: [
                _DateChip(
                    icon: Icons.play_circle_outline,
                    label: _fmt(item.startDate)),
                const SizedBox(width: 12),
                if (item.endDate != null)
                  _DateChip(
                      icon: Icons.flag_outlined, label: _fmt(item.endDate!)),
              ],
            ),
            const SizedBox(height: 12),

            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${item.daysElapsed} / ${item.duration} ngày',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary)),
                Text('Còn ${item.daysRemaining} ngày',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Builder(builder: (_) {
                final percent = item.duration > 0
                    ? (item.daysElapsed / item.duration).clamp(0.0, 1.0)
                    : 0.0;
                final progressColor = percent < 0.3
                    ? Colors.red
                    : percent < 0.7
                        ? Colors.orange
                        : Colors.green;
                return LinearProgressIndicator(
                  value: percent,
                  minHeight: 7,
                  backgroundColor: progressColor.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                );
              }),
            ),
            const SizedBox(height: 12),

            // CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.calendar_month_rounded, size: 15),
                label: const Text('Xem lịch tập'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
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
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DateChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ],
      );
}

// ── Tab 2: Calendar ───────────────────────────────────────────────────────────
class _CalendarTab extends StatefulWidget {
  final _WorkoutItem? selected;
  const _CalendarTab({this.selected});

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _viewMonth = widget.selected?.startDate ?? DateTime.now();
  }

  @override
  void didUpdateWidget(_CalendarTab old) {
    super.didUpdateWidget(old);
    if (widget.selected != null && widget.selected != old.selected) {
      setState(() => _viewMonth = widget.selected!.startDate);
    }
  }

  void _prev() =>
      setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1));
  void _next() =>
      setState(() => _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1));

  @override
  Widget build(BuildContext context) {
    if (widget.selected == null) {
      return const Center(
        child: Text('Chọn một gói hoặc dịch vụ để xem lịch',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    final item = widget.selected!;
    final markedSet = item.markedDays;
    final isMembership = item is _MembershipItem;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item.color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  isMembership
                      ? Icons.card_membership_rounded
                      : Icons.fitness_center_rounded,
                  size: 16,
                  color: item.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item.title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: item.color)),
                ),
                Text(
                  isMembership
                      ? '${item.daysElapsed} ngày đã tập'
                      : '${markedSet.length} buổi đã đặt',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: item.color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Calendar card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                // Month nav
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
                  child: Row(
                    children: [
                      Text(_monthName(_viewMonth),
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary)),
                      const Spacer(),
                      IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _prev,
                          color: AppTheme.textSecondary),
                      IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _next,
                          color: AppTheme.textSecondary),
                    ],
                  ),
                ),
                // Weekday headers
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN']
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(d,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textSecondary)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                  child: _buildGrid(_viewMonth, markedSet, item),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Legend
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _LegendDot(color: item.color, label: isMembership ? 'Đã tập' : 'Có lịch'),
              const _LegendDot(
                  color: Color(0xFFE8EEF5),
                  label: 'Trong gói',
                  textColor: Color.fromARGB(255, 102, 102, 102)),
              _LegendDot(color: AppTheme.warning, label: 'Hôm nay'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(DateTime month, Set<DateTime> markedSet, _WorkoutItem item) {
    final firstDay = DateTime(month.year, month.month, 1);
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    final startKey = DateTime(
        item.startDate.year, item.startDate.month, item.startDate.day);
    final endKey = item.endDate != null
        ? DateTime(item.endDate!.year, item.endDate!.month, item.endDate!.day)
        : null;

    final cells = <Widget>[];
    for (var i = 0; i < startOffset; i++) cells.add(const SizedBox());

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final isMarked = markedSet.contains(date);
      final isToday = date == todayKey;
      final isInRange = !date.isBefore(startKey) &&
          (endKey == null || !date.isAfter(endKey));

      Color bgColor = Colors.transparent;
      Color textColor = AppTheme.textPrimary;

      if (isToday) {
        bgColor = AppTheme.warning;
        textColor = Colors.white;
      } else if (isMarked) {
        bgColor = item.color;
        textColor = Colors.white;
      } else if (isInRange) {
        bgColor = const Color(0xFFE8EEF5);
        textColor = AppTheme.textSecondary;
      }

      cells.add(Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Center(
          child: Text('$day',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: (isMarked || isToday)
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: textColor)),
        ),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: cells,
    );
  }

  String _monthName(DateTime d) {
    const months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final Color? textColor;
  const _LegendDot({required this.color, required this.label, this.textColor});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: textColor ?? AppTheme.textPrimary,
                  fontWeight: FontWeight.w500)),
        ],
      );
}

// ── Error view ────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              Text(error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: onRetry, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
}
