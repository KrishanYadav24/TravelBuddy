import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Reusable Debug Navigation Drawer to test end-to-end routing on all feature screens.
class DebugNavigationDrawer extends StatelessWidget {
  const DebugNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    final routes = [
      {'name': 'Onboarding', 'path': '/onboarding', 'icon': Icons.explore},
      {'name': 'Authentication', 'path': '/auth', 'icon': Icons.lock},
      {'name': 'Activity Selector', 'path': '/activity-selector', 'icon': Icons.hiking},
      {'name': 'Interactive Map', 'path': '/map', 'icon': Icons.map},
      {'name': 'Destination Detail (Sample ID: 101)', 'path': '/destination/101', 'icon': Icons.place},
      {'name': 'Wishlist', 'path': '/wishlist', 'icon': Icons.favorite},
      {'name': 'Itinerary', 'path': '/itinerary', 'icon': Icons.event_note},
      {'name': 'Offline Mode', 'path': '/offline', 'icon': Icons.wifi_off},
      {'name': 'Community', 'path': '/community', 'icon': Icons.groups},
      {'name': 'User Profile', 'path': '/profile', 'icon': Icons.person},
      {'name': 'Emergency SOS', 'path': '/emergency', 'icon': Icons.warning_amber},
    ];

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TravelBuddy',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Route & Theme Debug Navigation',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primaryLight,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: routes.map((r) {
                  final path = r['path'] as String;
                  final isSelected = currentRoute == path ||
                      (path.startsWith('/destination/') && currentRoute.startsWith('/destination/'));

                  return ListTile(
                    leading: Icon(
                      r['icon'] as IconData,
                      color: isSelected ? AppColors.accent : AppColors.textSecondary,
                    ),
                    title: Text(
                      r['name'] as String,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? AppColors.primary : AppColors.textPrimary,
                          ),
                    ),
                    subtitle: Text(
                      path,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    selected: isSelected,
                    selectedTileColor: AppColors.primaryLight.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                    ),
                    onTap: () {
                      Navigator.pop(context); // close drawer
                      if (!isSelected) {
                        context.go(path);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
