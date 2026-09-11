import '../models/destination.dart';

class SimilarityService {
  /// Calculate similarity score between two destinations (0.0 to 1.0)
  /// Enforces category boundary (different categories get 0.0 or severe penalty)
  static double calculateSimilarity(Destination source, Destination candidate) {
    if (source.id == candidate.id) return 0.0;

    // Category mismatch penalty
    if (source.category != candidate.category) {
      return 0.0; // Strictly scoped to same category
    }

    double score = 0.5; // Base score for matching category

    // 1. SubType match (+0.3)
    if (source.subType != null &&
        candidate.subType != null &&
        source.subType!.toLowerCase() == candidate.subType!.toLowerCase()) {
      score += 0.3;
    }

    // 2. Region / State match (+0.2)
    if (source.state.toLowerCase() == candidate.state.toLowerCase()) {
      score += 0.2;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Get top similar destinations within the same category
  static List<Destination> getSimilarDestinations(
    Destination target,
    List<Destination> allDestinations, {
    int limit = 4,
  }) {
    final candidates = allDestinations.where((d) => d.id != target.id && d.category == target.category).toList();
    candidates.sort((a, b) {
      final scoreA = calculateSimilarity(target, a);
      final scoreB = calculateSimilarity(target, b);
      return scoreB.compareTo(scoreA);
    });

    return candidates.take(limit).toList();
  }
}
