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
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedSubTypes = ref.watch(selectedSubTypesProvider);
    final selectedLegacyIds = ref.watch(selectedActivitiesProvider);

    final isAnySelected = selectedCategory != null || selectedSubTypes.isNotEmpty || selectedLegacyIds.isNotEmpty;

    // Find current active category object if selected
    final activeCategoryObj = ActivityType.staticActivities.firstWhere(
      (a) => a.id == selectedCategory,
      orElse: () => ActivityType.staticActivities.first,
    );

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Screen Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What kind of trip are you planning?',
                    style: AppTypography.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select a category to customize your adventure',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Primary 5 Category Grid Tiles
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 1.15,
                ),
                itemCount: ActivityType.staticActivities.length,
                itemBuilder: (context, index) {
                  final category = ActivityType.staticActivities[index];
                  final isSelected = selectedCategory == category.id;

                  return _CategoryTile(
                    category: category,
                    isSelected: isSelected,
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).selectCategory(category.id);
                      // Sync legacy provider for backwards compatibility with existing filters
                      ref.read(selectedActivitiesProvider.notifier).toggleActivity(category.id);
                    },
                  );
                },
              ),
            ),

            // 3. Sub-type Filter Chips Row (Appears when a category is selected)
            if (selectedCategory != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                color: AppColors.primary.withValues(alpha: 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${activeCategoryObj.label} Sub-Types:',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        if (selectedSubTypes.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              ref.read(selectedSubTypesProvider.notifier).clearSubTypes();
                            },
                            child: Text(
                              'Clear sub-types',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: activeCategoryObj.subTypes.map((subType) {
                          final isSubSelected = selectedSubTypes.contains(subType);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(subType),
                              selected: isSubSelected,
                              selectedColor: AppColors.primary,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                color: isSubSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSubSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (_) {
                                ref.read(selectedSubTypesProvider.notifier).toggleSubType(subType);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 4. Persistent Bottom Navigation & CTA Bar
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
                  ElevatedButton(
                    onPressed: isAnySelected
                        ? () {
                            context.go('/map');
                          }
                        : null,
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
                              ? 'Explore Map →'
                              : 'Select at least 1 activity category',
                          style: AppTypography.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isAnySelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
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

class _CategoryTile extends StatelessWidget {
  final ActivityType category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
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
              CachedNetworkImage(
                imageUrl: category.backgroundImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.primaryLight),
                errorWidget: (context, url, error) => Container(color: AppColors.primary),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category.iconData,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category.label,
                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
              Positioned(
                top: 6,
                right: 6,
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
                      size: 22,
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
