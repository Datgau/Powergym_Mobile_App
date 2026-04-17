class UserMembership {
  final int id;
  final String membershipId;
  final String packageName;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // ACTIVE, EXPIRED, PENDING
  final int duration;
  final double price;
  final List<String> features;
  final String? color;

  const UserMembership({
    required this.id,
    required this.membershipId,
    required this.packageName,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.duration,
    required this.price,
    required this.features,
    this.color,
  });

  factory UserMembership.fromJson(Map<String, dynamic> json) {
    final pkg = json['membershipPackage'] as Map<String, dynamic>?;
    List<String> featureList = [];
    final raw = pkg?['features'];
    if (raw is List) {
      featureList = raw.map((e) => e.toString()).toList();
    } else if (raw is String && raw.isNotEmpty) {
      featureList = raw.split(',').map((e) => e.trim()).toList();
    }

    return UserMembership(
      id: json['id'] as int,
      membershipId: json['membershipId'] as String? ?? '${json['id']}',
      packageName: pkg?['name'] as String? ?? json['packageName'] as String? ?? '',
      description: pkg?['description'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String? ?? 'ACTIVE',
      duration: pkg?['duration'] as int? ?? json['duration'] as int? ?? 30,
      price: (pkg?['price'] as num? ?? json['price'] as num? ?? 0).toDouble(),
      features: featureList,
      color: pkg?['color'] as String?,
    );
  }

  bool get isActive => status == 'ACTIVE';

  int get daysRemaining => endDate.difference(DateTime.now()).inDays.clamp(0, 9999);

  int get daysElapsed =>
      DateTime.now().difference(startDate).inDays.clamp(0, duration);

  double get progressPercent => (daysElapsed / duration).clamp(0.0, 1.0);

  /// Tất cả ngày từ startDate đến hôm nay (đã tập)
  List<DateTime> get trainedDays {
    final today = DateTime.now();
    final end = today.isBefore(endDate) ? today : endDate;
    final days = <DateTime>[];
    var d = DateTime(startDate.year, startDate.month, startDate.day);
    final endDay = DateTime(end.year, end.month, end.day);
    while (!d.isAfter(endDay)) {
      days.add(d);
      d = d.add(const Duration(days: 1));
    }
    return days;
  }
}
