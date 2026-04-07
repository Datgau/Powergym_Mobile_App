import 'package:flutter/material.dart';

// ── Package Status Enum ────────────────────────────────────────────
enum PackageStatus { active, expired, pending }

// ── Training Package Model ─────────────────────────────────────────
class TrainingPackage {
  final String id;
  final String name;
  final String emoji;
  final int totalSessions;
  final int usedSessions;
  final DateTime startDate;
  final DateTime endDate;
  final String trainerName;
  final PackageStatus status;
  final double price;

  const TrainingPackage({
    required this.id,
    required this.name,
    required this.emoji,
    required this.totalSessions,
    required this.usedSessions,
    required this.startDate,
    required this.endDate,
    required this.trainerName,
    required this.status,
    required this.price,
  });

  int get remainingSessions => totalSessions - usedSessions;
  double get progressPercent => usedSessions / totalSessions;
  int get daysRemaining => endDate.difference(DateTime.now()).inDays.clamp(0, 9999);
}

// ── Package Plan Model ─────────────────────────────────────────────
class PackagePlan {
  final String name;
  final String emoji;
  final String sessions;
  final String duration;
  final double price;
  final List<String> features;
  final bool isPopular;
  final bool isVip;
  final Color accentColor;

  const PackagePlan({
    required this.name,
    required this.emoji,
    required this.sessions,
    required this.duration,
    required this.price,
    required this.features,
    this.isPopular = false,
    this.isVip = false,
    required this.accentColor,
  });
}
