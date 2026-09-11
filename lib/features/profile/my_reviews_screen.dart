import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockUserReviews = [
      {
        'destinationName': 'Kedarkantha Peak Trek',
        'rating': 5.0,
        'date': 'January 2026',
        'reviewText':
            'Summit day sunrise was unreal! Watching the snow turn golden on Bandarpoonch was magical.',
      },
      {
        'destinationName': 'Valley of Flowers Trek',
        'rating': 4.5,
        'date': 'August 2025',
        'reviewText':
            'Incredible explosion of colors in August! The climb from Govindghat to Ghangaria is paved, but carry rain poncho.',
      },
      {
        'destinationName': 'Chopta, Chandrashila & Tungnath',
        'rating': 5.0,
        'date': 'May 2025',
        'reviewText':
            'Red rhododendrons in full bloom along the trail to Tungnath. Very doable for beginners!',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
      ),
      body: mockUserReviews.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text('No reviews submitted yet', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Share your experience on any destination detail page.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockUserReviews.length,
              itemBuilder: (context, index) {
                final rev = mockUserReviews[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                rev['destinationName'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${rev['rating']}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rev['date'] as String,
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          rev['reviewText'] as String,
                          style: const TextStyle(fontSize: 13, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
