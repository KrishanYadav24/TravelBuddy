import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/destination.dart';
import '../providers/map_filter_provider.dart';

class MapFilterModal extends ConsumerWidget {
  const MapFilterModal({super.key});

  static const List<String> availableCategories = [
    'Trekking & Hiking',
    'Wildlife & Safari Expeditions',
    'Cultural Immersion Trips',
    'Wellness & Relaxation Escapes',
    'Road Trips',
  ];

  static const List<String> availableTerrains = [
    'Alpine Meadow & River Valleys',
    'Pine Forests & Snow Ridge',
    'Rhododendron Ridge',
    'Tall Elephant Grass & Floodplain',
    'Sal Forest & River Basin',
    'Bouldered Landscape & Temple Complex',
    'Rural Desert Outskirts',
    'Naga Hills & Tribal Village',
    'Coastal Lagoon & Canal Villages',
    'Ganges River Valley & Foothills',
    'Arabian Sea Beach & Coconut Palms',
    'Coffee Estate & Rainforest',
    'High-Altitude Alpine Passes',
    'Winding Coastal Ridges',
    'White Salt Desert',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(mapFilterProvider);
    final filterNotifier = ref.read(mapFilterProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Drag Handle & Title
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Destinations',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (filterState.hasActiveFilters)
                    TextButton(
                      onPressed: () => filterNotifier.resetFilters(),
                      child: const Text('Reset All', style: TextStyle(color: AppColors.accentAlt)),
                    ),
                ],
              ),
              const Divider(height: 24),

              // 0. Primary Category Filter Chips
              Text(
                'Trip Category',
                style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableCategories.map((cat) {
                  final isSelected = filterState.selectedCategories.contains(cat);
                  return FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    onSelected: (_) => filterNotifier.toggleCategory(cat),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 1. Difficulty Level Chips
              Text(
                'Difficulty Level (Trekking & Safari)',
                style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: DifficultyLevel.values.map((level) {
                  final isSelected = filterState.selectedDifficulties.contains(level);
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: level.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(level.label),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
                    checkmarkColor: AppColors.primary,
                    onSelected: (_) => filterNotifier.toggleDifficulty(level),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 2. Maximum Duration Filter Chips
              Text(
                'Maximum Duration',
                style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _durationChip('Any Duration', null, filterState.maxDurationDays, filterNotifier),
                  _durationChip('3 Days or Less', 3, filterState.maxDurationDays, filterNotifier),
                  _durationChip('5 Days or Less', 5, filterState.maxDurationDays, filterNotifier),
                  _durationChip('8 Days or Less', 8, filterState.maxDurationDays, filterNotifier),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Terrain Type Filter Chips
              Text(
                'Terrain & Environment',
                style: AppTypography.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableTerrains.map((terrain) {
                  final isSelected = filterState.selectedTerrains.contains(terrain);
                  return FilterChip(
                    label: Text(terrain),
                    selected: isSelected,
                    selectedColor: AppColors.accent.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.accent,
                    onSelected: (_) => filterNotifier.toggleTerrain(terrain),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Apply CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _durationChip(
    String label,
    int? days,
    int? currentMaxDays,
    MapFilterNotifier notifier,
  ) {
    final isSelected = currentMaxDays == days;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
      onSelected: (_) => notifier.setMaxDuration(days),
    );
  }
}
