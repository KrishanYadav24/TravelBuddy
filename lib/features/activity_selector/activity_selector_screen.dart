import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/debug_navigation_drawer.dart';
import '../../models/activity_type.dart';
import 'providers/activity_provider.dart';

class ActivitySelectorScreen extends ConsumerWidget {
  const ActivitySelectorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(selectedActivitiesProvider);
    final isAnySelected = selectedIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Selector'),
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
        child: Column(
          children: [
            // 1. Screen Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What kind of trip are you planning?',
                    style: AppTypography.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick one or more — we\'ll show you spots that match',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 2. 2-Column Grid of 8 Activity Tiles
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14.0,
                  mainAxisSpacing: 14.0,
                  childAspectRatio: 1.1,
                ),
                itemCount: ActivityType.staticActivities.length,
                itemBuilder: (context, index) {
                  final activity = ActivityType.staticActivities[index];
                  final isSelected = selectedIds.contains(activity.id);

                  return _ActivityTile(
                    activity: activity,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(selectedActivitiesProvider.notifier).toggleActivity(activity.id);
                    },
                  );
                },
              ),
            ),

            // 3. Persistent Bottom Navigation & CTA Bar
            Container(
              padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Persistent CTA "Explore Map →" button
                  ElevatedButton(
                    onPressed: isAnySelected
                        ? () {
                            context.go('/map');
                          }
                        : null, // Disabled state when 0 selected
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAnySelected ? AppColors.accent : AppColors.border,
                      disabledBackgroundColor: AppColors.border,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isAnySelected
                              ? 'Explore Map (${selectedIds.length}) →'
                              : 'Select at least 1 activity',
                          style: AppTypography.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isAnySelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Secondary text link: "Or browse by state instead"
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/browse-by-state'),
                      child: Text(
                        'Or browse by state instead',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
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

/// Single Activity Card Widget with 150ms selection animation
class _ActivityTile extends StatelessWidget {
  final ActivityType activity;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityTile({
    required this.activity,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 3.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background photo
              // TODO: Replace picsum network images with production SVGs / assets
              CachedNetworkImage(
                imageUrl: activity.backgroundImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.primaryLight),
                errorWidget: (context, url, error) => Container(color: AppColors.primary),
              ),

              // Gradient Overlay for text legibility
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),

              // Icon + Label
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      activity.iconData,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.label,
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        shadows: const [
                          Shadow(blurRadius: 4.0, color: Colors.black54),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Selection Checkmark Badge (top-right corner)
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutBack,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
