class ChatMessage {
  final String role; // "user" or "assistant"
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? '',
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ServiceCard {
  final int id;
  final String name;
  final String? description;
  final double? price;
  final String? priceFormatted;
  final int? duration;
  final int? maxParticipants;
  final String? category;
  final List<String> images;
  final String? thumbnail;

  ServiceCard({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.priceFormatted,
    this.duration,
    this.maxParticipants,
    this.category,
    this.images = const [],
    this.thumbnail,
  });

  factory ServiceCard.fromJson(Map<String, dynamic> json) {
    return ServiceCard(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price']?.toDouble(),
      priceFormatted: json['priceFormatted'],
      duration: json['duration'],
      maxParticipants: json['maxParticipants'],
      category: json['category'],
      images: List<String>.from(json['images'] ?? []),
      thumbnail: json['thumbnail'],
    );
  }
}

class MembershipCard {
  final int id;
  final String name;
  final String? description;
  final double? price;
  final String? priceFormatted;
  final String? originalPriceFormatted;
  final int? duration;
  final double? discount;
  final bool isPopular;
  final String? color;
  final List<String> features;

  MembershipCard({
    required this.id,
    required this.name,
    this.description,
    this.price,
    this.priceFormatted,
    this.originalPriceFormatted,
    this.duration,
    this.discount,
    this.isPopular = false,
    this.color,
    this.features = const [],
  });

  factory MembershipCard.fromJson(Map<String, dynamic> json) {
    return MembershipCard(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price']?.toDouble(),
      priceFormatted: json['priceFormatted'],
      originalPriceFormatted: json['originalPriceFormatted'],
      duration: json['duration'],
      discount: json['discount']?.toDouble(),
      isPopular: json['isPopular'] ?? false,
      color: json['color'],
      features: List<String>.from(json['features'] ?? []),
    );
  }
}

class TrainerSpecialty {
  final String name;
  final int? experienceYears;

  TrainerSpecialty({
    required this.name,
    this.experienceYears,
  });

  factory TrainerSpecialty.fromJson(Map<String, dynamic> json) {
    return TrainerSpecialty(
      name: json['name'] ?? '',
      experienceYears: json['experienceYears'],
    );
  }
}

class TrainerCard {
  final int id;
  final String fullName;
  final String? bio;
  final String? avatar;
  final int? totalExperienceYears;
  final List<TrainerSpecialty> specialties;

  TrainerCard({
    required this.id,
    required this.fullName,
    this.bio,
    this.avatar,
    this.totalExperienceYears,
    this.specialties = const [],
  });

  factory TrainerCard.fromJson(Map<String, dynamic> json) {
    return TrainerCard(
      id: json['id'] ?? 0,
      fullName: json['fullName'] ?? '',
      bio: json['bio'],
      avatar: json['avatar'],
      totalExperienceYears: json['totalExperienceYears'],
      specialties: (json['specialties'] as List<dynamic>?)
          ?.map((e) => TrainerSpecialty.fromJson(e))
          .toList() ?? [],
    );
  }
}

class ChatApiResponse {
  final String text;
  final List<ServiceCard>? services;
  final List<MembershipCard>? memberships;
  final List<TrainerCard>? trainers;

  ChatApiResponse({
    required this.text,
    this.services,
    this.memberships,
    this.trainers,
  });

  factory ChatApiResponse.fromJson(Map<String, dynamic> json) {
    return ChatApiResponse(
      text: json['text'] ?? '',
      services: (json['services'] as List<dynamic>?)
          ?.map((e) => ServiceCard.fromJson(e))
          .toList(),
      memberships: (json['memberships'] as List<dynamic>?)
          ?.map((e) => MembershipCard.fromJson(e))
          .toList(),
      trainers: (json['trainers'] as List<dynamic>?)
          ?.map((e) => TrainerCard.fromJson(e))
          .toList(),
    );
  }
}

class MessageWithCards {
  final ChatMessage message;
  final List<ServiceCard>? services;
  final List<MembershipCard>? memberships;
  final List<TrainerCard>? trainers;

  MessageWithCards({
    required this.message,
    this.services,
    this.memberships,
    this.trainers,
  });
}