import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/destination.dart';
import '../../wishlist/providers/wishlist_provider.dart';

class DestinationCard extends ConsumerWidget {
  final Destination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGoodTime = destination.isGoodTimeNow();
    final wishlistedIds = ref.watch(wishlistProvider);
    final isWishlisted = wishlistedIds.contains(destination.id);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.accent.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 1. 90x90 Thumbnail with CachedNetworkImage
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: SizedBox(
                width: 90,
                height: 90,
                child: CachedNetworkImage(
                  imageUrl: destination.photoUrls.isNotEmpty
                      ? destination.photoUrls.first
                      : 'https://picsum.photos/id/1018/300/300',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                  errorWidget: (context, url, error) => Container(color: AppColors.primaryLight),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 2. Destination Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          destination.name,
                          style: AppTypography.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Wishlist Bookmark Icon Button wired to wishlistProvider
                      IconButton(
                        icon: Icon(
                          isWishlisted ? Icons.bookmark : Icons.bookmark_border,
                          size: 22,
                          color: isWishlisted ? AppColors.accent : AppColors.textSecondary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: isWishlisted ? 'Remove from Wishlist' : 'Save to Wishlist',
                        onPressed: () {
                          ref.read(wishlistProvider.notifier).toggleWishlist(destination.id);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isWishlisted
                                    ? 'Removed "${destination.name}" from Wishlist'
                                    : 'Saved "${destination.name}" to Wishlist!',
                              ),
                              duration: const Duration(seconds: 2),
                              action: isWishlisted
                                  ? null
                                  : SnackBarAction(
                                      label: 'View Wishlist',
                                      onPressed: () => context.push('/wishlist'),
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // State & Region
                  Text(
                    '${destination.state} • ${destination.region}',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Difficulty colored dot + label (or category) & Weather badge
                  Row(
                    children: [
                      if (destination.difficulty != null) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: destination.difficulty!.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          destination.difficulty!.label,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: destination.difficulty!.color,
                          ),
                        ),
                      ] else ...[
                        Text(
                          destination.category,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      Icon(
                        isGoodTime ? Icons.wb_sunny : Icons.calendar_month,
                        size: 14,
                        color: isGoodTime ? AppColors.accent : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Best: ${destination.bestTimeText}',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            fontSize: 11,
                            color: isGoodTime ? AppColors.accentAlt : AppColors.textSecondary,
                            fontWeight: isGoodTime ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // "View Details" Affordance
                  GestureDetector(
                    onTap: () => context.go('/destination/${destination.id}'),
                    child: Text(
                      'View Details →',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
