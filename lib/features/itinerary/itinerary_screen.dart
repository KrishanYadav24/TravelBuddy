import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/debug_navigation_drawer.dart';
import '../../models/itinerary.dart';
import 'providers/itinerary_provider.dart';

class ItineraryScreen extends ConsumerWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itineraries = ref.watch(itineraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Trips & Itineraries',
          style: AppTypography.textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // "+ New Trip" App Bar Action
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
            tooltip: 'Create New Trip',
            onPressed: () => _showCreateTripDialog(context, ref),
          ),

          // Drawer Trigger
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const DebugNavigationDrawer(),
      body: itineraries.isEmpty
          ? _buildEmptyState(context, ref)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: itineraries.length,
              itemBuilder: (context, index) {
                final itinerary = itineraries[index];
                return _ItineraryCard(itinerary: itinerary);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        onPressed: () => _showCreateTripDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text(
          'New Trip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ===========================================================================
  // Dialog: Create New Trip
  // ===========================================================================
  void _showCreateTripDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Create New Trip'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g., Himalaya Trek July 2026',
              labelText: 'Trip Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final created = ref.read(itineraryProvider.notifier).createItinerary(name);
                  Navigator.of(dialogCtx).pop();
                  context.push('/itinerary/${created.id}');
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // Empty State Widget
  // ===========================================================================
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
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
                Icons.route_rounded,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No trips planned yet',
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new itinerary to group your favorite destinations into an organized multi-stop trail trip.',
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
              onPressed: () => _showCreateTripDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text(
                'Create Your First Trip',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SUB-WIDGET: Itinerary Card
// =============================================================================
class _ItineraryCard extends ConsumerWidget {
  final Itinerary itinerary;

  const _ItineraryCard({required this.itinerary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopCount = itinerary.stops.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.map_outlined, color: AppColors.primary, size: 24),
        ),
        title: Text(
          itinerary.name,
          style: AppTypography.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '$stopCount ${stopCount == 1 ? "stop" : "stops"} planned',
            style: AppTypography.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
              tooltip: 'Delete Trip',
              onPressed: () {
                _confirmDelete(context, ref);
              },
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
        onTap: () => context.push('/itinerary/${itinerary.id}'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Are you sure you want to delete "${itinerary.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(itineraryProvider.notifier).deleteItinerary(itinerary.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
