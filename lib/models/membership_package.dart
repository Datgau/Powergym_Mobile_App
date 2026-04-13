class MembershipPackage {
  final int id;
  final String packageId;
  final String name;
  final String? description;
  final int duration; // days
  final double price;
  final double? originalPrice;
  final int? discount;
  final List<String> features;
  final bool isPopular;
  final bool isActive;
  final String? color;

  MembershipPackage({
    required this.id,
    required this.packageId,
    required this.name,
    this.description,
    required this.duration,
    required this.price,
    this.originalPrice,
    this.discount,
    required this.features,
    required this.isPopular,
    required this.isActive,
    this.color,
  });

  // Factory constructor để map dữ liệu JSON từ Backend API trả về sang Object Flutter
  factory MembershipPackage.fromJson(Map<String, dynamic> json) {
    return MembershipPackage(
      id: json['id'] as int,
      packageId: json['packageId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      duration: json['duration'] as int,
      // Sử dụng (json['field'] as num).toDouble() để parse an toàn cho cả int và double
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      discount: json['discount'] as int?,
      // Ép kiểu mảng dynamic sang List<String>
      features: (json['features'] as List<dynamic>).cast<String>(),
      isPopular: json['isPopular'] as bool,
      isActive: json['isActive'] as bool,
      color: json['color'] as String?,
    );
  }

  // Các hàm getter (tiện ích) hỗ trợ format hiển thị nhanh trên UI
  String get formattedPrice => '${price.toStringAsFixed(0)}đ';

  String get formattedOriginalPrice => originalPrice != null
      ? '${originalPrice!.toStringAsFixed(0)}đ'
      : '';

  String get durationText => '$duration ngày';
}