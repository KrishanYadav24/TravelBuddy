import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Enum representing destination difficulty level.
enum DifficultyLevel {
  easy,
  moderate,
  difficult,
  expert;

  String get label {
    switch (this) {
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.moderate:
        return 'Moderate';
      case DifficultyLevel.difficult:
        return 'Difficult';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  Color get color {
    switch (this) {
      case DifficultyLevel.easy:
        return AppColors.success;
      case DifficultyLevel.moderate:
        return AppColors.warning;
      case DifficultyLevel.difficult:
        return AppColors.accentAlt;
      case DifficultyLevel.expert:
        return AppColors.danger;
    }
  }
}

/// Destination domain model.
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
  final List<String> photoUrls; // TODO: Replace placeholder network URLs with real photography
  final List<int> bestMonths; // 1-12
  final double avgRating;
  final int reviewCount;

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
  });

  /// Check whether current month falls within best months range.
  bool isGoodTimeNow() {
    final currentMonth = DateTime.now().month;
    return bestMonths.contains(currentMonth);
  }

  /// Formatted month range text (e.g. "May - Oct").
  String get bestTimeText {
    if (bestMonths.isEmpty) return 'Year round';
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (bestMonths.length == 12) return 'Year round';
    final firstMonth = monthNames[bestMonths.first - 1];
    final lastMonth = monthNames[bestMonths.last - 1];
    return '$firstMonth - $lastMonth';
  }
}
