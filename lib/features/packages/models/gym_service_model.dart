class GymService {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int? duration;
  final int? maxParticipants;
  final List<String> images;
  final ServiceCategory? category;
  final int? registrationCount;

  const GymService({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.duration,
    this.maxParticipants,
    required this.images,
    this.category,
    this.registrationCount,
  });

  factory GymService.fromJson(Map<String, dynamic> json) {
    return GymService(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] != null ? (json['duration'] as num).toInt() : null,
      maxParticipants: json['maxParticipants'] != null
          ? (json['maxParticipants'] as num).toInt()
          : null,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      category: json['category'] != null
          ? ServiceCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      registrationCount: json['registrationCount'] != null
          ? (json['registrationCount'] as num).toInt()
          : null,
    );
  }

  String get formattedPrice {
    final formatted = price.toStringAsFixed(0).split('').reversed
        .toList()
        .asMap()
        .entries
        .map((e) => e.key > 0 && e.key % 3 == 0 ? '${e.value}.' : e.value)
        .toList()
        .reversed
        .join();
    return '${formatted}đ';
  }

  String get durationText => duration != null ? '$duration ngày' : '';
}

class ServiceCategory {
  final int id;
  final String name;
  final String? displayName;
  final String? icon;
  final String? color;

  const ServiceCategory({
    required this.id,
    required this.name,
    this.displayName,
    this.icon,
    this.color,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      displayName: json['displayName'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  String get label => displayName ?? name;
}
