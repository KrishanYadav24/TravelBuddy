import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/env_config.dart';

class DestinationReview {
  final String id;
  final String destinationId;
  final String userName;
  final String userAvatarUrl;
  final double rating;
  final String comment;
  final List<String> photoUrls;
  final DateTime createdAt;

  const DestinationReview({
    required this.id,
    required this.destinationId,
    required this.userName,
    required this.userAvatarUrl,
    required this.rating,
    required this.comment,
    this.photoUrls = const [],
    required this.createdAt,
  });
}

class ReviewService {
  final List<DestinationReview> _mockReviews = [
    DestinationReview(
      id: 'rev_1',
      destinationId: 'kedarkantha',
      userName: 'Aarav Sharma',
      userAvatarUrl: 'https://picsum.photos/seed/aarav/100',
      rating: 5.0,
      comment: 'Unbelievable winter snow trek! The summit view of Swargarohini at sunrise was surreal.',
      photoUrls: ['https://picsum.photos/seed/kk_review1/600/400'],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    DestinationReview(
      id: 'rev_2',
      destinationId: 'valley_of_flowers',
      userName: 'Priya Patel',
      userAvatarUrl: 'https://picsum.photos/seed/priya/100',
      rating: 4.8,
      comment: 'Blossoms everywhere in August. Make sure to wear waterproof boots!',
      photoUrls: ['https://picsum.photos/seed/vof_review1/600/400'],
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
  ];

  Future<List<DestinationReview>> getReviewsForDestination(String destinationId) async {
    if (!EnvConfig.useMockData) {
      try {
        // Firestore Remote Fetching Integration Point
        // final snapshot = await FirebaseFirestore.instance.collection('reviews').where('destinationId', isEqualTo: destinationId).get();
      } catch (_) {}
    }
    return _mockReviews.where((r) => r.destinationId == destinationId || destinationId.isEmpty).toList();
  }

  Future<DestinationReview> addReview({
    required String destinationId,
    required String userName,
    required double rating,
    required String comment,
    List<String> photoPaths = const [],
  }) async {
    final newReview = DestinationReview(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      destinationId: destinationId,
      userName: userName,
      userAvatarUrl: 'https://picsum.photos/seed/new_user/100',
      rating: rating,
      comment: comment,
      photoUrls: photoPaths.isEmpty
          ? ['https://picsum.photos/seed/trek_upload/600/400']
          : photoPaths,
      createdAt: DateTime.now(),
    );

    _mockReviews.insert(0, newReview);
    return newReview;
  }
}

final reviewServiceProvider = Provider<ReviewService>((ref) => ReviewService());
