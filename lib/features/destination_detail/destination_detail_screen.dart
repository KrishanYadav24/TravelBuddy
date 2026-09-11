import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/debug_navigation_drawer.dart';
import '../../models/destination.dart';
import '../../services/destination_repository.dart';
import '../itinerary/providers/itinerary_provider.dart';
import '../map/widgets/destination_card.dart';
import '../wishlist/providers/wishlist_provider.dart';

class DestinationDetailScreen extends ConsumerStatefulWidget {
  final String destinationId;

  const DestinationDetailScreen({
    super.key,
    required this.destinationId,
  });

  @override
  ConsumerState<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState
    extends ConsumerState<DestinationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncDestinations = ref.watch(allDestinationsProvider);
    final allDestinations = asyncDestinations.asData?.value ?? [];

    final destination = allDestinations.firstWhere(
      (d) => d.id == widget.destinationId,
      orElse: () => allDestinations.isNotEmpty
          ? allDestinations.first
          : const Destination(
              id: 'fallback',
              name: 'Destination',
              activityTypes: ['trek'],
              state: 'India',
              region: 'Himalayas',
              lat: 28.6139,
              lng: 77.2090,
              difficulty: DifficultyLevel.easy,
              durationDays: 3,
              altitudeMeters: 2000,
              terrainType: 'Mountain',
              description: 'Destination details loading...',
              photoUrls: ['https://picsum.photos/seed/fallback/800/600'],
              bestMonths: [1, 2, 3],
              avgRating: 4.5,
              reviewCount: 10,
            ),
    );

    // Nearby destinations (excluding current)
    final nearbyDestinations = allDestinations
        .where((d) => d.id != destination.id)
        .take(4)
        .toList();

    return Scaffold(
      endDrawer: const DebugNavigationDrawer(),
      body: Stack(
        children: [
          // Main CustomScrollView
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // 1. Hero SliverAppBar with Carousel
                SliverAppBar(
                  expandedHeight: 320.0,
                  pinned: true,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.4),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
                  actions: [
                    // Frosted Share Button
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.4),
                        child: IconButton(
                          icon: const Icon(Icons.share, color: Colors.white, size: 18),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Share link copied for ${destination.name}!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Frosted Bookmark Button (Wired to wishlistProvider)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.4),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final wishlistedIds = ref.watch(wishlistProvider);
                            final isBookmarked = wishlistedIds.contains(destination.id);

                            return IconButton(
                              icon: Icon(
                                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                color: isBookmarked ? AppColors.accent : Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                ref.read(wishlistProvider.notifier).toggleWishlist(destination.id);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isBookmarked
                                          ? 'Removed "${destination.name}" from Wishlist'
                                          : 'Saved "${destination.name}" to Wishlist!',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    action: isBookmarked
                                        ? null
                                        : SnackBarAction(
                                            label: 'View Wishlist',
                                            onPressed: () => context.push('/wishlist'),
                                          ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // Navigation Drawer Trigger
                    Builder(
                      builder: (ctx) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.4),
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white, size: 20),
                            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                          ),
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: innerBoxIsScrolled
                        ? Text(
                            destination.name,
                            style: AppTypography.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          )
                        : null,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Photo Carousel
                        PageView.builder(
                          controller: _pageController,
                          itemCount: destination.photoUrls.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPhotoIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              destination.photoUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                                  child: const Icon(Icons.landscape, size: 64, color: AppColors.primary),
                                );
                              },
                            );
                          },
                        ),

                        // Gradient Overlay for Readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.4),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Title & Location Overlay (Bottom Left)
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                destination.name,
                                style: AppTypography.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: AppColors.accent, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${destination.region}, ${destination.state}',
                                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Carousel Dot Indicators (Bottom Center)
                        if (destination.photoUrls.length > 1)
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                destination.photoUrls.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: _currentPhotoIndex == index ? 16 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _currentPhotoIndex == index
                                        ? AppColors.accent
                                        : Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ];
            },

            // Body Content
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Padding for sticky bottom bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Info Chip Row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Difficulty Pill
                        _InfoPill(
                          icon: Icons.terrain,
                          label: destination.difficulty.label,
                          color: destination.difficulty.color,
                        ),
                        // Duration Pill
                        _InfoPill(
                          icon: Icons.timer,
                          label: '${destination.durationDays} Days',
                          color: AppColors.primary,
                        ),
                        // Altitude Pill
                        _InfoPill(
                          icon: Icons.filter_hdr,
                          label: '${destination.altitudeMeters}m Alt',
                          color: AppColors.primaryLight,
                        ),
                        // Rating Badge Pill
                        _InfoPill(
                          icon: Icons.star,
                          label: '${destination.avgRating} (${destination.reviewCount})',
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ),

                  // 3. Seasonal Weather Card
                  _WeatherCardWidget(destination: destination),

                  const SizedBox(height: 12),

                  // 4. TabBar
                  Container(
                    color: AppColors.surface,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Route & Map'),
                        Tab(text: 'Permits & Safety'),
                        Tab(text: 'Reviews'),
                        Tab(text: 'Nearby'),
                      ],
                    ),
                  ),

                  // TabBarView Content Height
                  SizedBox(
                    height: 460,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Overview
                        _OverviewTab(destination: destination),

                        // Tab 2: Route & Map
                        _RouteMapTab(destination: destination),

                        // Tab 3: Permits & Safety
                        _PermitsSafetyTab(destination: destination),

                        // Tab 4: Reviews
                        _ReviewsTab(destination: destination),

                        // Tab 5: Nearby
                        _NearbyTab(nearbyDestinations: nearbyDestinations),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Sticky Persistent Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Estimated Cost Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Estimated Cost',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            destination.estimatedCostRange,
                            style: AppTypography.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // "Add to Trip" Accent Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _showAddToTripModal(context, ref, destination);
                      },
                      label: const Text(
                        'Add to Trip',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ===========================================================================
  // Modal: Add Destination to Trip
  // ===========================================================================
  void _showAddToTripModal(BuildContext context, WidgetRef ref, Destination destination) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        final itineraries = ref.watch(itineraryProvider);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Add "${destination.name}" to trip',
                  style: AppTypography.textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select an existing itinerary or create a new one:',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),

                if (itineraries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No trips created yet.'),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: itineraries.length,
                      itemBuilder: (context, index) {
                        final trip = itineraries[index];
                        final alreadyAdded = trip.stops.any((s) => s.destinationId == destination.id);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.map_outlined, color: AppColors.primary),
                          title: Text(trip.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${trip.stops.length} stops'),
                          trailing: alreadyAdded
                              ? const Chip(
                                  label: Text('Added', style: TextStyle(fontSize: 11, color: Colors.green)),
                                  backgroundColor: Color(0x1F4CAF50),
                                )
                              : const Icon(Icons.add_circle_outline, color: AppColors.accent),
                          onTap: alreadyAdded
                              ? null
                              : () {
                                  ref.read(itineraryProvider.notifier).addStop(trip.id, destination.id);
                                  Navigator.of(modalCtx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Added "${destination.name}" to ${trip.name}'),
                                      action: SnackBarAction(
                                        label: 'View Trip',
                                        onPressed: () => context.push('/itinerary/${trip.id}'),
                                      ),
                                    ),
                                  );
                                },
                        );
                      },
                    ),
                  ),

                const Divider(height: 24),

                // Button: Create New Trip
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.of(modalCtx).pop();
                      _showCreateTripAndAdd(context, ref, destination);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('+ Create New Trip', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateTripAndAdd(BuildContext context, WidgetRef ref, Destination destination) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Create New Trip'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g., Summer Backpacking 2026',
            labelText: 'Trip Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final created = ref.read(itineraryProvider.notifier).createItinerary(name);
                ref.read(itineraryProvider.notifier).addStop(created.id, destination.id);
                Navigator.of(dialogCtx).pop();
                context.push('/itinerary/${created.id}');
              }
            },
            child: const Text('Create & Add'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGET: Info Pill
// =============================================================================
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGET: Weather & Seasonality Card
// =============================================================================
/*
================================================================================
TODO: REAL WEATHER API INTEGRATION POINT
================================================================================
To wire real-time weather data:
1. Replace mock values below with a WeatherRepository call (e.g., OpenWeatherMap API).
2. Fetch live forecast using destination coordinates `(destination.lat, destination.lng)`.
3. Provide reactive weather state via Riverpod `weatherProvider(destinationId)`.
================================================================================
*/
class _WeatherCardWidget extends StatelessWidget {
  final Destination destination;

  const _WeatherCardWidget({required this.destination});

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Weather Conditions Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Weather (Base Camp)',
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '14°C • Mostly Sunny (Feels like 12°C)',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.wb_sunny_outlined, color: AppColors.accent, size: 28),
            ],
          ),
          const SizedBox(height: 12),

          // 5-Day Forecast Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ForecastDayChip(day: 'Today', temp: '14°', icon: Icons.wb_sunny),
              _ForecastDayChip(day: 'Tomorrow', temp: '12°', icon: Icons.cloud),
              _ForecastDayChip(day: 'Wed', temp: '10°', icon: Icons.ac_unit),
              _ForecastDayChip(day: 'Thu', temp: '13°', icon: Icons.wb_cloudy),
              _ForecastDayChip(day: 'Fri', temp: '15°', icon: Icons.wb_sunny),
            ],
          ),
          const Divider(height: 24),

          // 12-Month Best Time Strip Header
          Text(
            'Best Months to Visit',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),

          // 12-Month Horizontal Strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(12, (index) {
                final monthNum = index + 1;
                final isBest = destination.bestMonths.contains(monthNum);
                final isCurrent = monthNum == currentMonth;

                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isBest
                        ? AppColors.primary
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: isCurrent
                        ? Border.all(color: AppColors.accent, width: 2)
                        : Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    monthNames[index],
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: isBest || isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isBest ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastDayChip extends StatelessWidget {
  final String day;
  final String temp;
  final IconData icon;

  const _ForecastDayChip({
    required this.day,
    required this.temp,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(day, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(temp, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 1: OVERVIEW
// =============================================================================
class _OverviewTab extends StatelessWidget {
  final Destination destination;

  const _OverviewTab({required this.destination});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'About this Trail',
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          destination.description,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.terrain, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terrain Type',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    destination.terrainType,
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// TAB 2: ROUTE & MAP
// =============================================================================
class _RouteMapTab extends StatelessWidget {
  final Destination destination;

  const _RouteMapTab({required this.destination});

  @override
  Widget build(BuildContext context) {
    // TODO: Stub for full route GPS trail & elevation profile snippet.
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trail Map & Coordinates',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'GPS Coordinates: ${destination.lat.toStringAsFixed(4)}°N, ${destination.lng.toStringAsFixed(4)}°E',
            style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Non-Interactive GoogleMap Snippet
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 220,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(destination.lat, destination.lng),
                  zoom: 11.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(destination.id),
                    position: LatLng(destination.lat, destination.lng),
                    infoWindow: InfoWindow(title: destination.name),
                  ),
                },
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Elevation Profile: Base ${destination.altitudeMeters - 1200}m ➔ Summit ${destination.altitudeMeters}m',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TAB 3: PERMITS & SAFETY
// =============================================================================
class _PermitsSafetyTab extends StatelessWidget {
  final Destination destination;

  const _PermitsSafetyTab({required this.destination});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Conditional Red Alert Banner Widget
        if (destination.hasActiveAlert && destination.activeAlertText != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentAlt),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: AppColors.accentAlt, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    destination.activeAlertText!,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.accentAlt,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Permit Information
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.assignment, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Forest & Local Permits',
                    style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(destination.permitInfo, style: AppTypography.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Nearest Medical Facility
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.local_hospital, color: AppColors.accentAlt),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nearest Medical Facility',
                    style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(destination.nearestHospital, style: AppTypography.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Network Coverage
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cell_tower, color: AppColors.primaryLight),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cellular Network & Connectivity',
                    style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(destination.networkCoverage, style: AppTypography.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// TAB 4: REVIEWS
// =============================================================================
class _ReviewsTab extends StatelessWidget {
  final Destination destination;

  const _ReviewsTab({required this.destination});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Community Reviews',
                  style: AppTypography.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '★ ${destination.avgRating} out of 5.0 (${destination.reviewCount} reports)',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Trip report submission opens after login.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('+ Add Report'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Mock Reviews List
        if (destination.mockReviews.isEmpty)
          const Text('No reviews submitted yet for this destination.')
        else
          ...destination.mockReviews.map((rev) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(rev.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(rev.dateStr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < rev.rating.floor() ? Icons.star : Icons.star_border,
                        size: 14,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(rev.reviewText, style: AppTypography.textTheme.bodyMedium),
                ],
              ),
            );
          }),
      ],
    );
  }
}

// =============================================================================
// TAB 5: NEARBY
// =============================================================================
class _NearbyTab extends StatelessWidget {
  final List<Destination> nearbyDestinations;

  const _NearbyTab({required this.nearbyDestinations});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Nearby Spots',
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: nearbyDestinations.length,
              itemBuilder: (context, index) {
                final dest = nearbyDestinations[index];
                return SizedBox(
                  width: 280,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DestinationCard(
                      destination: dest,
                      isSelected: false,
                      onTap: () {
                        context.go('/destination/${dest.id}');
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
