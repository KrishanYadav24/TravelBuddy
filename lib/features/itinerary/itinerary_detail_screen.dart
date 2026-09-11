import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/debug_navigation_drawer.dart';
import '../../models/destination.dart';
import '../../models/itinerary.dart';
import '../../services/destination_repository.dart';
import 'providers/itinerary_provider.dart';

class ItineraryDetailScreen extends ConsumerStatefulWidget {
  final String itineraryId;

  const ItineraryDetailScreen({
    super.key,
    required this.itineraryId,
  });

  @override
  ConsumerState<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends ConsumerState<ItineraryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final itineraries = ref.watch(itineraryProvider);
    final itinerary = itineraries.firstWhere(
      (t) => t.id == widget.itineraryId,
      orElse: () => Itinerary(
        id: widget.itineraryId,
        name: 'Trip Details',
        stops: const [],
        createdAt: DateTime.now(),
      ),
    );

    final asyncDestinations = ref.watch(allDestinationsProvider);
    final allDestinations = asyncDestinations.asData?.value ?? [];

    // Resolve stops to actual Destination objects
    final stopDestinations = <Destination>[];
    for (var stop in itinerary.stops) {
      final found = allDestinations.firstWhere(
        (d) => d.id == stop.destinationId,
        orElse: () => Destination(
          id: stop.destinationId,
          name: 'Unknown Spot (${stop.destinationId})',
          activityTypes: ['trek'],
          state: 'India',
          region: 'Himalayas',
          lat: 28.6139,
          lng: 77.2090,
          difficulty: DifficultyLevel.easy,
          durationDays: 1,
          altitudeMeters: 1000,
          terrainType: 'Mountain',
          description: '',
          photoUrls: ['https://picsum.photos/seed/stop/300/300'],
          bestMonths: [1],
          avgRating: 4.0,
          reviewCount: 1,
        ),
      );
      stopDestinations.add(found);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          itinerary.name,
          style: AppTypography.textTheme.headlineMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
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
          // 1. Mini Static Map Preview with Connected Polyline
          _buildMapHeader(stopDestinations),

          // 2. Add Stop Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${itinerary.stops.length} Stops (Hold & drag to reorder)',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to Map in Selection Mode
                    context.push('/map?selectModeForTripId=${itinerary.id}');
                  },
                  icon: const Icon(Icons.add_location_alt, size: 16),
                  label: const Text(
                    '+ Add Stop',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // 3. Reorderable ListView of Stops
          Expanded(
            child: itinerary.stops.isEmpty
                ? _buildEmptyStopsState(context, itinerary.id)
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: itinerary.stops.length,
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(itineraryProvider.notifier)
                          .reorderStops(itinerary.id, oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final stop = itinerary.stops[index];
                      final destination = stopDestinations[index];

                      return Dismissible(
                        key: ValueKey(stop.destinationId),
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
                              Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        onDismissed: (direction) {
                          ref
                              .read(itineraryProvider.notifier)
                              .removeStop(itinerary.id, stop.destinationId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed "${destination.name}" from itinerary'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: _ItineraryStopTile(
                          key: ValueKey('tile_${stop.destinationId}'),
                          stop: stop,
                          destination: destination,
                          index: index,
                          onPickDate: () => _pickDateForStop(context, stop, itinerary.id),
                          onTap: () => context.push('/destination/${destination.id}'),
                        ),
                      );
                    },
                  ),
          ),

          // 4. Bottom Actions: Export as PDF & Download Offline Maps
          _buildBottomActions(context, itinerary),
        ],
      ),
    );
  }

  // ===========================================================================
  // Mini Map Header Widget
  // ===========================================================================
  Widget _buildMapHeader(List<Destination> destinations) {
    if (destinations.isEmpty) {
      return Container(
        height: 160,
        color: AppColors.primaryLight.withValues(alpha: 0.1),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 40, color: AppColors.primary),
              SizedBox(height: 8),
              Text('No stops added to map preview yet', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    final points = destinations.map((d) => LatLng(d.lat, d.lng)).toList();
    final center = LatLng(
      destinations.map((d) => d.lat).reduce((a, b) => a + b) / destinations.length,
      destinations.map((d) => d.lng).reduce((a, b) => a + b) / destinations.length,
    );

    final markers = <Marker>{};
    for (int i = 0; i < destinations.length; i++) {
      final d = destinations[i];
      markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: LatLng(d.lat, d.lng),
          infoWindow: InfoWindow(title: '${i + 1}. ${d.name}'),
        ),
      );
    }

    final polyline = Polyline(
      polylineId: const PolylineId('route_polyline'),
      points: points,
      color: AppColors.accent,
      width: 4,
    );

    return SizedBox(
      height: 180,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: center,
          zoom: 7.0,
        ),
        markers: markers,
        polylines: {polyline},
        zoomControlsEnabled: false,
        scrollGesturesEnabled: false,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
      ),
    );
  }

  // ===========================================================================
  // Empty Stops State
  // ===========================================================================
  Widget _buildEmptyStopsState(BuildContext context, String itineraryId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_location_alt_outlined, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            const Text(
              'No stops added to this trip yet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap "+ Add Stop" to pick destinations from the interactive map.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => context.push('/map?selectModeForTripId=$itineraryId'),
              icon: const Icon(Icons.map),
              label: const Text('Pick Spots on Map'),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Date Picker Dialog
  // ===========================================================================
  Future<void> _pickDateForStop(BuildContext context, ItineraryStop stop, String tripId) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: stop.plannedDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 730)),
    );

    if (picked != null) {
      ref
          .read(itineraryProvider.notifier)
          .updateStopDate(tripId, stop.destinationId, picked);
    }
  }

  // ===========================================================================
  // Bottom Action Bar
  // ===========================================================================
  Widget _buildBottomActions(BuildContext context, Itinerary itinerary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Export as PDF (Stub Button)
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  /*
                  ==============================================================
                  TODO: PDF EXPORT INTEGRATION POINT
                  Requires `pdf` + `printing` package. Generates a printable PDF
                  doc containing destination stops, dates, and trail permits.
                  ==============================================================
                  */
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export as PDF: Feature stub (PDF package integration ready)'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf, size: 18, color: AppColors.primary),
                label: const Text(
                  'Export PDF',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Download Offline Maps CTA
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  context.push('/offline');
                },
                icon: const Icon(Icons.download_for_offline, size: 18),
                label: const Text(
                  'Offline Maps',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGET: Stop Tile for ReorderableListView
// =============================================================================
class _ItineraryStopTile extends StatelessWidget {
  final ItineraryStop stop;
  final Destination destination;
  final int index;
  final VoidCallback onPickDate;
  final VoidCallback onTap;

  const _ItineraryStopTile({
    super.key,
    required this.stop,
    required this.destination,
    required this.index,
    required this.onPickDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = stop.plannedDate != null
        ? '${stop.plannedDate!.day}/${stop.plannedDate!.month}/${stop.plannedDate!.year}'
        : 'Set Date';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Stop Index Badge
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),

            // Destination Thumbnail Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: CachedNetworkImage(
                  imageUrl: destination.photoUrls.isNotEmpty
                      ? destination.photoUrls.first
                      : 'https://picsum.photos/id/1018/300/300',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          destination.name,
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              '${destination.state} • ${destination.durationDays}d',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 8),

            // Date Picker Chip
            GestureDetector(
              onTap: onPickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 11, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.drag_handle, color: Colors.grey),
      ),
    );
  }
}
