import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum DifficultyLevel {
  easy('Easy', AppColors.primaryLight),
  moderate('Moderate', AppColors.accent),
  difficult('Difficult', AppColors.accentAlt),
  expert('Expert', Color(0xFF8B0000));

  final String label;
  final Color color;

  const DifficultyLevel(this.label, this.color);
}

class DestinationReview {
  final String authorName;
  final double rating;
  final String dateStr;
  final String reviewText;
  final String? photoUrl;

  const DestinationReview({
    required this.authorName,
    required this.rating,
    required this.dateStr,
    required this.reviewText,
    this.photoUrl,
  });
}

class Destination {
  final String id;
  final String name;
  final List<String> activityTypes;
  final String state;
  final String region;
  final double lat;
  final double lng;
  final DifficultyLevel difficulty;
  final int durationDays;
  final int altitudeMeters;
  final String terrainType;
  final String description;
  final List<String> photoUrls;
  final List<int> bestMonths; // 1 = Jan, 12 = Dec
  final double avgRating;
  final int reviewCount;

  // Additional detail fields
  final bool hasActiveAlert;
  final String? activeAlertText;
  final String permitInfo;
  final String nearestHospital;
  final String networkCoverage;
  final String estimatedCostRange;
  final List<DestinationReview> mockReviews;

  const Destination({
    required this.id,
    required this.name,
    required this.activityTypes,
    required this.state,
    required this.region,
    required this.lat,
    required this.lng,
    required this.difficulty,
    required this.durationDays,
    required this.altitudeMeters,
    required this.terrainType,
    required this.description,
    required this.photoUrls,
    required this.bestMonths,
    required this.avgRating,
    required this.reviewCount,
    this.hasActiveAlert = false,
    this.activeAlertText,
    this.permitInfo = 'No special permits required for Indian citizens. Carry valid photo ID.',
    this.nearestHospital = 'District Hospital (approx. 25km from base village).',
    this.networkCoverage = 'Moderate BSNL/Jio coverage at base. Patchy on trail.',
    this.estimatedCostRange = '₹4,000 - ₹8,500 / person',
    this.mockReviews = const [],
  });

  /// Returns true if the current month is in [bestMonths]
  bool isGoodTimeNow() {
    final currentMonth = DateTime.now().month;
    return bestMonths.contains(currentMonth);
  }

  /// Returns readable best time text string (e.g., "Jul - Sep")
  String get bestTimeText {
    if (bestMonths.isEmpty) return 'Year round';
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final start = monthNames[bestMonths.first - 1];
    final end = monthNames[bestMonths.last - 1];
    if (start == end) return start;
    return '$start - $end';
  }
}
