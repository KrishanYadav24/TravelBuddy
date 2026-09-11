import '../../models/destination.dart';
import '../../models/user_profile.dart';
import '../weather_service.dart';

/// Abstract Recommendation Strategy interface
abstract class RecommendationStrategy {
  /// Calculate recommendation score (higher is better, range typically 0 - 100)
  double calculateScore({
    required Destination destination,
    required UserProfile profile,
    WeatherInfo? weather,
  });
}

/// Strategy for Trekking & Hiking / Wildlife & Safari
class TrekkingWildlifeStrategy implements RecommendationStrategy {
  @override
  double calculateScore({
    required Destination destination,
    required UserProfile profile,
    WeatherInfo? weather,
  }) {
    double score = 50.0;

    // 1. Seasonality (bestMonths)
    if (destination.isGoodTimeNow()) {
      score += 25.0;
    }

    // 2. Weather Risk
    if (weather != null) {
      if (weather.riskScore == 0) score += 15.0;
      if (weather.riskScore == 1) score += 5.0;
      if (weather.riskScore == 2) score -= 20.0; // Moderate penalty for severe weather
    }

    // 3. Fitness Level Matching
    if (destination.difficulty != null) {
      final difficulty = destination.difficulty!;
      switch (profile.fitnessLevel.name) {
        case 'beginner':
          if (difficulty == DifficultyLevel.easy) score += 15.0;
          if (difficulty == DifficultyLevel.moderate) score += 10.0;
          if (difficulty == DifficultyLevel.difficult || difficulty == DifficultyLevel.expert) score -= 15.0;
          break;
        case 'intermediate':
          if (difficulty == DifficultyLevel.moderate) score += 15.0;
          if (difficulty == DifficultyLevel.easy || difficulty == DifficultyLevel.difficult) score += 10.0;
          break;
        case 'advanced':
          if (difficulty == DifficultyLevel.difficult || difficulty == DifficultyLevel.expert) score += 20.0;
          if (difficulty == DifficultyLevel.easy) score -= 5.0;
          break;
      }
    }

    // 4. Rating Boost
    score += (destination.avgRating * 2.0);

    return score.clamp(0.0, 100.0);
  }
}

/// Strategy for Wellness & Relaxation Escapes
class WellnessStrategy implements RecommendationStrategy {
  @override
  double calculateScore({
    required Destination destination,
    required UserProfile profile,
    WeatherInfo? weather,
  }) {
    double score = 40.0;

    // 1. Program Schedule Availability (primary factor)
    if (destination.programSchedule != null && destination.programSchedule!.isNotEmpty) {
      score += 30.0; // High score for defined upcoming retreats
    }

    // 2. Wellness Focus Match with User Preferences
    if (destination.wellnessFocus != null) {
      final focus = destination.wellnessFocus!.toLowerCase();
      final matchedPref = profile.wellnessPreferences.any((pref) => focus.contains(pref.toLowerCase()));
      if (matchedPref) {
        score += 20.0;
      }
    }

    // 3. Seasonality (Secondary factor for wellness)
    if (destination.isGoodTimeNow()) {
      score += 10.0;
    }

    // Fitness level is intentionally ignored for Wellness.
    score += (destination.avgRating * 1.5);

    return score.clamp(0.0, 100.0);
  }
}

/// Strategy for Cultural Immersion Trips
class CulturalStrategy implements RecommendationStrategy {
  @override
  double calculateScore({
    required Destination destination,
    required UserProfile profile,
    WeatherInfo? weather,
  }) {
    double score = 40.0;

    // 1. Festival / Event Date Proximity parsing (primary factor)
    bool hasTimeSensitiveEvent = false;
    if (destination.culturalHighlights != null) {
      for (final highlight in destination.culturalHighlights!) {
        final lower = highlight.toLowerCase();
        if (lower.contains('october') || lower.contains('november') || lower.contains('festival') || lower.contains('fair')) {
          hasTimeSensitiveEvent = true;
          break;
        }
      }
    }
    if (hasTimeSensitiveEvent) {
      score += 25.0;
    }

    // 2. Cultural Interests Match with User Profile
    if (destination.culturalHighlights != null) {
      int matchCount = 0;
      for (final interest in profile.culturalInterests) {
        final interestLower = interest.toLowerCase();
        for (final highlight in destination.culturalHighlights!) {
          if (highlight.toLowerCase().contains(interestLower)) {
            matchCount++;
            break;
          }
        }
      }
      score += (matchCount * 10.0);
    }

    // 3. SubType Matching
    final subTypeLower = destination.subType?.toLowerCase() ?? '';
    if (subTypeLower.isNotEmpty && profile.culturalInterests.any((i) => subTypeLower.contains(i.toLowerCase()))) {
      score += 10.0;
    }

    // Fitness level is intentionally ignored for Cultural.
    score += (destination.avgRating * 1.5);

    return score.clamp(0.0, 100.0);
  }
}

/// Strategy for Road Trips
class RoadTripStrategy implements RecommendationStrategy {
  @override
  double calculateScore({
    required Destination destination,
    required UserProfile profile,
    WeatherInfo? weather,
  }) {
    double score = 50.0;

    // 1. Heavy Weather Weighting (Landslides, Monsoon & Visibility on Highway Drives)
    if (weather != null) {
      if (weather.riskScore == 0) {
        score += 25.0; // Clear roads & great visibility
      } else if (weather.riskScore == 1) {
        score -= 10.0; // Rain alert
      } else if (weather.riskScore == 2) {
        score -= 40.0; // Severe monsoon/blizzard risk penalty for mountain/coastal drives
      }
    } else if (destination.isGoodTimeNow()) {
      score += 15.0;
    } else {
      score -= 25.0; // Bad month penalty for road trips
    }

    // 2. Preferred Duration Band Matching
    final preferredDuration = profile.roadTripDuration; // Weekend, 4-7 days, 7+ days
    final days = destination.durationDays ?? 3;
    if (preferredDuration == 'Weekend' && days <= 3) {
      score += 15.0;
    } else if (preferredDuration == '4-7 days' && days >= 4 && days <= 7) {
      score += 15.0;
    } else if (preferredDuration == '7+ days' && days > 7) {
      score += 15.0;
    }

    // Fitness level is intentionally ignored for Road Trips.
    score += (destination.avgRating * 1.5);

    return score.clamp(0.0, 100.0);
  }
}

/// Factory to select RecommendationStrategy based on destination category
class RecommendationStrategyFactory {
  static RecommendationStrategy getStrategy(String category) {
    switch (category) {
      case 'Wellness & Relaxation Escapes':
        return WellnessStrategy();
      case 'Cultural Immersion Trips':
        return CulturalStrategy();
      case 'Road Trips':
        return RoadTripStrategy();
      case 'Trekking & Hiking':
      case 'Wildlife & Safari Expeditions':
      default:
        return TrekkingWildlifeStrategy();
    }
  }
}
