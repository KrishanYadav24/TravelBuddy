import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/debug_navigation_drawer.dart';
import '../../models/destination.dart';
import 'providers/map_filter_provider.dart';
import 'widgets/destination_card.dart';
import 'widgets/map_filter_modal.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  String? _selectedDestinationId;

  // Default initial camera position for India
  static const LatLng _indiaCenter = LatLng(22.5937, 78.9629);
  static const double _initialZoom = 4.8;

  final ScrollController _listScrollController = ScrollController();

  @override
  void dispose() {
    _mapController?.dispose();
    _listScrollController.dispose();
    super.dispose();
  }

  void _recenterToIndia() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_indiaCenter, _initialZoom),
    );
  }

  void _onSelectDestination(Destination dest, {bool centerMap = true}) {
    setState(() {
      _selectedDestinationId = dest.id;
    });

    if (centerMap && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(dest.lat, dest.lng),
          9.0, // Zoom level for detailed view
        ),
      );
    }
  }

  /// Get marker hue based on primary activity type
  double _getActivityHue(String primaryActivity) {
    switch (primaryActivity) {
      case 'trek':
        return BitmapDescriptor.hueGreen;
      case 'hike':
        return BitmapDescriptor.hueAzure;
      case 'safari':
        return BitmapDescriptor.hueOrange;
      case 'beach':
        return BitmapDescriptor.hueCyan;
      case 'heritage':
        return BitmapDescriptor.hueYellow;
      case 'camping':
        return BitmapDescriptor.hueRose;
      case 'road_trip':
        return BitmapDescriptor.hueViolet;
      case 'pilgrimage':
        return BitmapDescriptor.hueMagenta;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDestinations = ref.watch(filteredDestinationsProvider);
    final filterState = ref.watch(mapFilterProvider);

    // Sort destinations by "weather fit" (current month matches best time)
    final sortedDestinations = List<Destination>.from(filteredDestinations)
      ..sort((a, b) {
        final aFit = a.isGoodTimeNow() ? 1 : 0;
        final bFit = b.isGoodTimeNow() ? 1 : 0;
        return bFit.compareTo(aFit);
      });

    // TODO: For large marker counts (>50), integrate google_maps_cluster_manager for pin clustering
    final Set<Marker> markers = sortedDestinations.map((dest) {
      final isSelected = dest.id == _selectedDestinationId;
      final primaryActivity = dest.activityTypes.isNotEmpty ? dest.activityTypes.first : 'trek';

      return Marker(
        markerId: MarkerId(dest.id),
        position: LatLng(dest.lat, dest.lng),
        infoWindow: InfoWindow(
          title: dest.name,
          snippet: '${dest.state} • ${dest.difficulty.label}',
          onTap: () => context.go('/destination/${dest.id}'),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueRed : _getActivityHue(primaryActivity),
        ),
        onTap: () => _onSelectDestination(dest, centerMap: true),
      );
    }).toSet();

    return Scaffold(
      endDrawer: const DebugNavigationDrawer(),
      body: Stack(
        children: [
          // 1. Full-screen GoogleMap Widget
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _indiaCenter,
              zoom: _initialZoom,
            ),
            markers: markers,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // 2. Transparent/Frosted Top App Bar Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.88),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => context.canPop() ? context.pop() : context.go('/activity-selector'),
                    tooltip: 'Back to Activity Selector',
                  ),
                  const SizedBox(width: 4),

                  // Search TextField Placeholder
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Search destinations or states...',
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Filter Modal Button
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: filterState.hasActiveFilters
                              ? AppColors.accent
                              : AppColors.textPrimary,
                        ),
                        tooltip: 'Filter Destinations',
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const MapFilterModal(),
                          );
                        },
                      ),
                      if (filterState.hasActiveFilters)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 3. Floating Action Button: Recenter to India View
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.20,
            child: FloatingActionButton.small(
              heroTag: 'recenter_fab',
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primary,
              onPressed: _recenterToIndia,
              tooltip: 'Recenter to India View',
              child: const Icon(Icons.center_focus_strong),
            ),
          ),

          // 4. Draggable Scrollable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.22,
            minChildSize: 0.14,
            maxChildSize: 0.72,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Sheet Drag Handle & Title Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: Column(
                        children: [
                          Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recommended for now',
                                style: AppTypography.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${sortedDestinations.length} spots',
                                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Destination List
                    Expanded(
                      child: sortedDestinations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.explore_off, size: 40, color: AppColors.textSecondary),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No destinations match your filters.',
                                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => ref.read(mapFilterProvider.notifier).resetFilters(),
                                    child: const Text('Clear Filters'),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                              itemCount: sortedDestinations.length,
                              itemBuilder: (context, index) {
                                final dest = sortedDestinations[index];
                                final isSelected = dest.id == _selectedDestinationId;

                                return DestinationCard(
                                  destination: dest,
                                  isSelected: isSelected,
                                  onTap: () => _onSelectDestination(dest, centerMap: true),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
