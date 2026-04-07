import 'package:flutter/material.dart';

// ── User Profile Model ─────────────────────────────────────────────
class UserProfile {
  final String fullName;
  final String email;
  final String phone;
  final String membershipTier;
  final DateTime memberSince;
  final int totalSessions;
  final int weekStreak;
  final double trainerRating;
  final double weightGoalKg;
  final double currentWeightKg;
  final double heightCm;

  const UserProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.membershipTier,
    required this.memberSince,
    required this.totalSessions,
    required this.weekStreak,
    required this.trainerRating,
    required this.weightGoalKg,
    required this.currentWeightKg,
    required this.heightCm,
  });

  double get bmi => currentWeightKg / ((heightCm / 100) * (heightCm / 100));
}

// ── Achievement Model ──────────────────────────────────────────────
class Achievement {
  final String emoji;
  final String name;
  final String subtitle;
  final bool unlocked;

  const Achievement({
    required this.emoji,
    required this.name,
    required this.subtitle,
    required this.unlocked,
  });
}

// ── Favorite Trainer Model ────────────────────────────────────────
class FavoriteTrainer {
  final String name;
  final String specialty;
  final double rating;
  final String emoji;
  final Color color;

  const FavoriteTrainer({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.emoji,
    required this.color,
  });
}
