import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/debug_navigation_drawer.dart';
import '../../models/destination.dart';
import '../../services/destination_repository.dart';
import '../map/widgets/destination_card.dart';
import 'providers/wishlist_provider.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  bool _isGridView = false;
  String _selectedActivityFilter = 'All';

  final List<String> _activityFilters = [
    'All',
    'Trek',
    'Hike',
    'Wildlife Safari',
    'Beach',
    'Heritage/Monument',
    'Camping',
    'Road Trip',
    'Pilgrimage',
  ];

  @override
  Widget build(BuildContext context) {
    final wishlistedIds = ref.watch(wishlistProvider);
    final asyncDestinations = ref.watch(allDestinationsProvider);
    final allDestinations = asyncDestinations.asData?.value ?? [];

    // Filter all destinations down to those in wishlistProvider
    final wishlistedDestinations = allDestinations
        .where((dest) => wishlistedIds.contains(dest.id))
        .toList();

    // Apply activity filter chip if selected
    final filteredDestinations = _selectedActivityFilter == 'All'
        ? wishlistedDestinations
        : wishlistedDestinations.where((dest) {
            final filterLower = _selectedActivityFilter.toLowerCase();
            return dest.activityTypes.any((act) => act.toLowerCase().contains(filterLower) || filterLower.contains(act.toLowerCase()));
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Wishlist',
          style: AppTypography.textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Grid / List View Toggle Button
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: AppColors.primary,
            ),
            tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),

          // Navigation Drawer Trigger
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const DebugNavigationDrawer(),
      body: Column(
        children: [
          // Quick Filter Chips Row (Shown when wishlist is non-empty)
          if (wishlistedDestinations.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _activityFilters.length,
                itemBuilder: (context, index) {
                  final filter = _activityFilters[index];
                  final isSelected = _selectedActivityFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(filter),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.background,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedActivityFilter = filter;
                        });
                      },
                    ),
                  );
                },
              ),
            ),

          // Main Body: Wishlist Content / Empty State
          Expanded(
            child: wishlistedDestinations.isEmpty
                ? _buildEmptyState(context)
                : filteredDestinations.isEmpty
                    ? Center(
                        child: Text(
                          'No "$_selectedActivityFilter" destinations saved.',
                          style: AppTypography.textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : _isGridView
                        ? _buildGridView(filteredDestinations, ref)
                        : _buildListView(filteredDestinations, ref),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Empty State Widget
  // ===========================================================================
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_outline_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nothing saved yet',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on any destination card or detail screen to save your favorite spots for later.',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => context.go('/map'),
              icon: const Icon(Icons.explore),
              label: const Text(
                'Explore Spots on Map',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // List View with Swipe-to-Remove (Dismissible)
  // ===========================================================================
  Widget _buildListView(List<Destination> destinations, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];

        return Dismissible(
          key: Key(destination.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete_outline, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Remove',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          onDismissed: (direction) {
            // Remove from wishlist
            ref.read(wishlistProvider.notifier).removeWishlist(destination.id);

            // Show Undo SnackBar
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Removed "${destination.name}" from Wishlist'),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: AppColors.accent,
                  onPressed: () {
                    ref.read(wishlistProvider.notifier).addWishlist(destination.id);
                  },
                ),
              ),
            );
          },
          child: DestinationCard(
            destination: destination,
            isSelected: false,
            onTap: () => context.push('/destination/${destination.id}'),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // Grid View Layout
  // ===========================================================================
  Widget _buildGridView(List<Destination> destinations, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: destinations.length,
      itemBuilder: (context, index) {
        final destination = destinations[index];

        return Dismissible(
          key: Key('grid_${destination.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
          ),
          onDismissed: (direction) {
            ref.read(wishlistProvider.notifier).removeWishlist(destination.id);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Removed "${destination.name}" from Wishlist'),
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: AppColors.accent,
                  onPressed: () {
                    ref.read(wishlistProvider.notifier).addWishlist(destination.id);
                  },
                ),
              ),
            );
          },
          child: _WishlistGridTile(
            destination: destination,
            onTap: () => context.push('/destination/${destination.id}'),
          ),
        );
      },
    );
  }
}

// =============================================================================
// SUB-WIDGET: Grid Tile Card
// =============================================================================
class _WishlistGridTile extends ConsumerWidget {
  final Destination destination;
  final VoidCallback onTap;

  const _WishlistGridTile({
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Thumbnail + Bookmark Icon
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: destination.photoUrls.isNotEmpty
                          ? destination.photoUrls.first
                          : 'https://picsum.photos/id/1018/300/300',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                      errorWidget: (context, url, error) => Container(color: AppColors.primaryLight),
                    ),
                  ),

                  // Bookmark Button Top Right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: IconButton(
                        icon: const Icon(Icons.bookmark, color: AppColors.accent, size: 16),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ref.read(wishlistProvider.notifier).removeWishlist(destination.id);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed "${destination.name}" from Wishlist'),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor: AppColors.accent,
                                onPressed: () {
                                  ref.read(wishlistProvider.notifier).addWishlist(destination.id);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Text Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${destination.state} • ${destination.region}',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
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
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: destination.difficulty!.color,
                          ),
                        ),
                      ] else ...[
                        Text(
                          destination.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                      const Spacer(),
                      const Icon(Icons.star, size: 12, color: AppColors.accent),
                      const SizedBox(width: 2),
                      Text(
                        destination.avgRating.toString(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
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
