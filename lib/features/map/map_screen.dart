import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/debug_navigation_drawer.dart';
import '../../models/activity_type.dart';
import '../activity_selector/providers/activity_provider.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedActivitiesProvider);
    final theme = Theme.of(context);

    // Find full activity details for selected IDs
    final selectedActivities = ActivityType.staticActivities
        .where((a) => selectedIds.contains(a.id))
        .toList();

    // Log to debug console to confirm state propagation
    if (kDebugMode) {
      print('MapScreen: Received selected activity IDs: ${selectedIds.toList()}');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Map'),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              tooltip: 'Open Route Menu',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const DebugNavigationDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  boxShadow: AppTheme.softShadowList,
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                      child: const Icon(Icons.map, size: 36, color: AppColors.accent),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Interactive Trail Map',
                      style: theme.textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Display selected activities state
                    if (selectedIds.isEmpty)
                      const Chip(
                        avatar: Icon(Icons.info_outline, size: 18),
                        label: Text('No Activities Selected (Showing All Trails)'),
                        backgroundColor: AppColors.background,
                      )
                    else ...[
                      Text(
                        'Filtered by ${selectedIds.length} Selected Activity Types:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: selectedActivities.map((act) {
                          return Chip(
                            avatar: Icon(act.iconData, size: 18, color: AppColors.primary),
                            label: Text('${act.label} (${act.id})'),
                            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.2),
                            side: const BorderSide(color: AppColors.primary, width: 1),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Text(
                      'The Map feature will render interactive Google Maps/Mapbox markers filtered by your selected activities.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.navigation),
                      label: const Text('Test Route Navigation'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
