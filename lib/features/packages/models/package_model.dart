/// ─── Package models ───────────────────────────────────────────────────────────

class MembershipPackage {
  final int id;
  final String name;
  final String? description;
  final int duration;
  final double price;
  final List<String> features;
  final bool isActive;

  const MembershipPackage({
    required this.id,
    required this.name,
    this.description,
    required this.duration,
    required this.price,
    required this.features,
    required this.isActive,
  });

  factory MembershipPackage.fromJson(Map<String, dynamic> json) {
    List<String> featureList = [];
    final raw = json['features'];
    if (raw is List) {
      featureList = raw.map((e) => e.toString()).toList();
    } else if (raw is String && raw.isNotEmpty) {
      featureList = raw.split(',').map((e) => e.trim()).toList();
    }

    return MembershipPackage(
      id:          json['id'] as int,
      name:        json['name'] as String? ?? '',
      description: json['description'] as String?,
      duration:    json['duration'] as int? ?? 30,
      price:       (json['price'] as num?)?.toDouble() ?? 0,
      features:    featureList,
      isActive:    json['isActive'] as bool? ?? true,
    );
  }

  String get formattedPrice {
    final parts = price.toInt().toString().split('').reversed.toList();
    final result = <String>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0 && i % 3 == 0) result.add('.');
      result.add(parts[i]);
    }
    return '${result.reversed.join()}đ';
  }

  String get durationText => '$duration ngày';
}
