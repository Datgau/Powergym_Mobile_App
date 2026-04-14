class TrainerEarnings {
  final double totalSalary;
  final List<ServiceEarning> serviceBreakdown;
  final DateTime calculatedAt;

  const TrainerEarnings({
    required this.totalSalary,
    required this.serviceBreakdown,
    required this.calculatedAt,
  });

  factory TrainerEarnings.fromJson(Map<String, dynamic> json) => TrainerEarnings(
        totalSalary: (json['totalSalary'] as num?)?.toDouble() ?? 0,
        serviceBreakdown: (json['serviceBreakdown'] as List<dynamic>? ?? [])
            .map((e) => ServiceEarning.fromJson(e as Map<String, dynamic>))
            .toList(),
        calculatedAt: json['calculatedAt'] != null
            ? DateTime.parse(json['calculatedAt'] as String)
            : DateTime.now(),
      );

  factory TrainerEarnings.empty() => TrainerEarnings(
        totalSalary: 0,
        serviceBreakdown: [],
        calculatedAt: DateTime.now(),
      );
}

class ServiceEarning {
  final int serviceId;
  final String serviceName;
  final int studentCount;
  final double servicePrice;
  final double trainerPercentage;
  final double salaryAmount;

  const ServiceEarning({
    required this.serviceId,
    required this.serviceName,
    required this.studentCount,
    required this.servicePrice,
    required this.trainerPercentage,
    required this.salaryAmount,
  });

  factory ServiceEarning.fromJson(Map<String, dynamic> json) => ServiceEarning(
        serviceId: json['serviceId'] as int? ?? 0,
        serviceName: json['serviceName'] as String? ?? '',
        studentCount: json['studentCount'] as int? ?? 0,
        servicePrice: (json['servicePrice'] as num?)?.toDouble() ?? 0,
        trainerPercentage: (json['trainerPercentage'] as num?)?.toDouble() ?? 0,
        salaryAmount: (json['salaryAmount'] as num?)?.toDouble() ?? 0,
      );
}
