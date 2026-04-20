import 'package:flutter/material.dart';
import 'package:powergym_mobile_app/config/theme.dart';
import 'package:powergym_mobile_app/core/network/api.dart';
import '../models/client_model.dart';

/// Chi tiết học viên - hiển thị thông tin, service và lịch tập luyện
class ClientDetailScreen extends StatefulWidget {
  final ClientModel client;
  
  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<_ClientDetailData>? _future;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _load() {
    final newFuture = _fetchClientDetail();
    setState(() => _future = newFuture);
  }

  Future<_ClientDetailData> _fetchClientDetail() async {
    // Fetch service registration details and bookings
    final res = await Api.private.get('/service-registrations/${widget.client.registrationId}');
    final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
    
    return _ClientDetailData.fromJson(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: FutureBuilder<_ClientDetailData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snap.hasError) {
            return _ErrorView(onRetry: _load, error: snap.error.toString());
          }
          
          final detail = snap.data!;
          
          return CustomScrollView(
            slivers: [
              // App Bar with client info
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppTheme.primaryBlue,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: ClipOval(
                                child: widget.client.avatar != null
                                    ? Image.network(
                                        widget.client.avatar!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _AvatarFallback(name: widget.client.fullName),
                                      )
                                    : _AvatarFallback(name: widget.client.fullName),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.client.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.client.email,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryBlue,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: AppTheme.primaryBlue,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Thông tin'),
                      Tab(text: 'Dịch vụ'),
                      Tab(text: 'Lịch tập'),
                    ],
                  ),
                ),
              ),
              
              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _InfoTab(client: widget.client, detail: detail),
                    _ServiceTab(detail: detail),
                    _ScheduleTab(detail: detail),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Data Models
// ══════════════════════════════════════════════════════════════════════════════

class _ClientDetailData {
  final String serviceName;
  final String? serviceDescription;
  final double servicePrice;
  final int serviceDuration;
  final String registrationDate;
  final String? expirationDate;
  final String status;
  final int totalBookings;
  final List<_BookingItem> upcomingBookings;
  final List<_BookingItem> completedBookings;

  const _ClientDetailData({
    required this.serviceName,
    this.serviceDescription,
    required this.servicePrice,
    required this.serviceDuration,
    required this.registrationDate,
    this.expirationDate,
    required this.status,
    required this.totalBookings,
    required this.upcomingBookings,
    required this.completedBookings,
  });

  factory _ClientDetailData.fromJson(Map<String, dynamic> json) {
    final service = json['gymService'] as Map<String, dynamic>? ?? json['service'] as Map<String, dynamic>?;
    final upcomingList = json['upcomingBookings'] as List? ?? [];
    final completedList = json['completedBookings'] as List? ?? [];
    
    return _ClientDetailData(
      serviceName: service?['name'] as String? ?? 'Service',
      serviceDescription: service?['description'] as String?,
      servicePrice: (service?['price'] as num?)?.toDouble() ?? 0,
      serviceDuration: service?['duration'] as int? ?? 0,
      registrationDate: json['registrationDate'] as String? ?? '',
      expirationDate: json['expirationDate'] as String? ?? json['endDate'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      totalBookings: json['totalBookings'] as int? ?? 0,
      upcomingBookings: upcomingList.map((e) => _BookingItem.fromJson(e as Map<String, dynamic>)).toList(),
      completedBookings: completedList.map((e) => _BookingItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class _BookingItem {
  final int id;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status;
  final String? notes;

  const _BookingItem({
    required this.id,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
  });

  factory _BookingItem.fromJson(Map<String, dynamic> json) => _BookingItem(
        id: json['id'] as int? ?? 0,
        bookingDate: json['bookingDate'] as String? ?? '',
        startTime: _trimSeconds(json['startTime'] as String? ?? ''),
        endTime: _trimSeconds(json['endTime'] as String? ?? ''),
        status: json['status'] as String? ?? '',
        notes: json['notes'] as String?,
      );

  static String _trimSeconds(String t) {
    if (t.length == 8 && t[2] == ':' && t[5] == ':') return t.substring(0, 5);
    return t;
  }

  DateTime get date {
    try {
      return DateTime.parse(bookingDate);
    } catch (_) {
      return DateTime.now();
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Tabs
// ══════════════════════════════════════════════════════════════════════════════

/// Tab 1: Thông tin học viên
class _InfoTab extends StatelessWidget {
  final ClientModel client;
  final _ClientDetailData detail;

  const _InfoTab({required this.client, required this.detail});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: 'Thông tin cá nhân',
            icon: Icons.person_rounded,
            children: [
              _InfoRow(label: 'Họ tên', value: client.fullName),
              _InfoRow(label: 'Email', value: client.email),
              _InfoRow(
                label: 'Trạng thái',
                value: client.isActive ? 'Đang hoạt động' : 'Không hoạt động',
                valueColor: client.isActive ? AppTheme.success : AppTheme.error,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Thống kê',
            icon: Icons.bar_chart_rounded,
            children: [
              _InfoRow(label: 'Tổng số buổi tập', value: '${detail.totalBookings}'),
              _InfoRow(label: 'Buổi sắp tới', value: '${detail.upcomingBookings.length}'),
              _InfoRow(label: 'Buổi đã hoàn thành', value: '${detail.completedBookings.length}'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tab 2: Thông tin dịch vụ
class _ServiceTab extends StatelessWidget {
  final _ClientDetailData detail;

  const _ServiceTab({required this.detail});

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return '—';
    try {
      final d = DateTime.parse(date);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return date;
    }
  }

  String _formatPrice(double price) {
    final parts = price.toInt().toString().split('').reversed.toList();
    final r = <String>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && i % 3 == 0) r.add('.');
      r.add(parts[i]);
    }
    return '${r.reversed.join()}đ';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionCard(
            title: detail.serviceName,
            icon: Icons.fitness_center_rounded,
            children: [
              if (detail.serviceDescription != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    detail.serviceDescription!,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ),
              _InfoRow(label: 'Giá dịch vụ', value: _formatPrice(detail.servicePrice)),
              _InfoRow(label: 'Thời lượng', value: '${detail.serviceDuration} phút'),
              _InfoRow(label: 'Ngày đăng ký', value: _formatDate(detail.registrationDate)),
              _InfoRow(label: 'Ngày hết hạn', value: _formatDate(detail.expirationDate)),
              _InfoRow(
                label: 'Trạng thái',
                value: detail.status == 'ACTIVE' ? 'Đang hoạt động' : detail.status,
                valueColor: detail.status == 'ACTIVE' ? AppTheme.success : AppTheme.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tab 3: Lịch tập luyện (Calendar view)
class _ScheduleTab extends StatefulWidget {
  final _ClientDetailData detail;

  const _ScheduleTab({required this.detail});

  @override
  State<_ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<_ScheduleTab> {
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayMonth = DateTime(now.year, now.month, 1);
  }

  DateTime get _rangeStart => DateTime.now();
  DateTime? get _rangeEnd {
    try {
      if (widget.detail.expirationDate == null) return null;
      return DateTime.parse(widget.detail.expirationDate!);
    } catch (_) {
      return null;
    }
  }

  bool _isInRange(DateTime day) {
    final end = _rangeEnd;
    if (end == null) return false;
    final d = DateTime(day.year, day.month, day.day);
    final s = DateTime(_rangeStart.year, _rangeStart.month, _rangeStart.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  bool _isEnd(DateTime day) {
    final end = _rangeEnd;
    if (end == null) return false;
    return day.year == end.year && day.month == end.month && day.day == end.day;
  }

  bool _hasBooking(DateTime day) {
    return widget.detail.upcomingBookings.any((b) {
      final bd = b.date;
      return bd.year == day.year && bd.month == day.month && bd.day == day.day;
    }) || widget.detail.completedBookings.any((b) {
      final bd = b.date;
      return bd.year == day.year && bd.month == day.month && bd.day == day.day;
    });
  }

  void _prevMonth() => setState(() => _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1, 1));
  void _nextMonth() => setState(() => _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1, 1));

  String _monthLabel(DateTime d) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(_displayMonth.year, _displayMonth.month);
    final firstWeekday = DateTime(_displayMonth.year, _displayMonth.month, 1).weekday;
    final rows = ((firstWeekday - 1 + daysInMonth) / 7).ceil();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), onPressed: _prevMonth),
              Text(_monthLabel(_displayMonth), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              IconButton(icon: const Icon(Icons.chevron_right), onPressed: _nextMonth),
            ],
          ),
          const SizedBox(height: 16),
          
          // Day labels
          Row(
            children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
                .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)))))
                .toList(),
          ),
          const SizedBox(height: 8),
          
          // Calendar grid
          ...List.generate(rows, (row) {
            return Row(
              children: List.generate(7, (col) {
                final cellIndex = row * 7 + col;
                final dayNum = cellIndex - (firstWeekday - 1) + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 44));
                }
                
                final day = DateTime(_displayMonth.year, _displayMonth.month, dayNum);
                final inRange = _isInRange(day);
                final isEnd = _isEnd(day);
                final isToday = _isToday(day);
                final hasBooking = _hasBooking(day);

                Color? bgColor;
                Color textColor = AppTheme.textPrimary;
                Color? circleColor;

                if (isEnd) {
                  circleColor = const Color(0xFFEF4444);
                  textColor = Colors.white;
                } else if (hasBooking) {
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
                        left: (col == 0 || dayNum == 1) ? const Radius.circular(22) : Radius.zero,
                        right: (col == 6 || dayNum == daysInMonth) ? const Radius.circular(22) : Radius.zero,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: circleColor != null ? FontWeight.w800 : inRange ? FontWeight.w600 : FontWeight.w400,
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
          
          const SizedBox(height: 20),
          
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _Legend(color: const Color(0xFF10B981), label: 'Hôm nay'),
              _Legend(color: AppTheme.primaryBlue.withOpacity(0.3), label: 'Thời gian hoạt động'),
              _Legend(color: AppTheme.primaryBlue, label: 'Có buổi tập'),
              _Legend(color: const Color(0xFFEF4444), label: 'Ngày hết hạn'),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Upcoming bookings list
          if (widget.detail.upcomingBookings.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Buổi tập sắp tới', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ),
            const SizedBox(height: 12),
            ...widget.detail.upcomingBookings.map((booking) => _BookingCard(booking: booking)),
          ],
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widgets
// ══════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor ?? AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final _BookingItem booking;

  const _BookingCard({required this.booking});

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EEF5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event_rounded, color: AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(booking.bookingDate), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Text('${booking.startTime} - ${booking.endTime}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(booking.status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.success)),
          ),
        ],
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
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;

  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final String error;

  const _ErrorView({required this.onRetry, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
            const SizedBox(height: 12),
            const Text('Không thể tải thông tin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Helper Delegate
// ══════════════════════════════════════════════════════════════════════════════

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
