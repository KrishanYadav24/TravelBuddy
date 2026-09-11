import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/destination.dart';
import '../../../services/destination_repository.dart';
import '../../activity_selector/providers/activity_provider.dart';
import '../../browse_by_state/providers/state_provider.dart';

/// State object representing active map filters.
class MapFilterState {
  final Set<String> selectedCategories;
  final Set<DifficultyLevel> selectedDifficulties;
  final Set<String> selectedTerrains;
  final int? maxDurationDays;

  const MapFilterState({
    this.selectedCategories = const {},
    this.selectedDifficulties = const {},
    this.selectedTerrains = const {},
    this.maxDurationDays,
  });

  MapFilterState copyWith({
    Set<String>? selectedCategories,
    Set<DifficultyLevel>? selectedDifficulties,
    Set<String>? selectedTerrains,
    int? maxDurationDays,
    bool clearMaxDuration = false,
  }) {
    return MapFilterState(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedDifficulties: selectedDifficulties ?? this.selectedDifficulties,
      selectedTerrains: selectedTerrains ?? this.selectedTerrains,
      maxDurationDays: clearMaxDuration ? null : (maxDurationDays ?? this.maxDurationDays),
    );
  }

  bool get hasActiveFilters =>
      selectedCategories.isNotEmpty ||
      selectedDifficulties.isNotEmpty ||
      selectedTerrains.isNotEmpty ||
      maxDurationDays != null;
}

class MapFilterNotifier extends Notifier<MapFilterState> {
  @override
  MapFilterState build() {
    return const MapFilterState();
  }

  void toggleCategory(String category) {
    final current = Set<String>.from(state.selectedCategories);
    if (current.contains(category)) {
      current.remove(category);
    } else {
      current.add(category);
    }
    state = state.copyWith(selectedCategories: current);
  }

  void toggleDifficulty(DifficultyLevel difficulty) {
    final current = Set<DifficultyLevel>.from(state.selectedDifficulties);
    if (current.contains(difficulty)) {
      current.remove(difficulty);
    } else {
      current.add(difficulty);
    }
    state = state.copyWith(selectedDifficulties: current);
  }

  void toggleTerrain(String terrain) {
    final current = Set<String>.from(state.selectedTerrains);
    if (current.contains(terrain)) {
      current.remove(terrain);
    } else {
      current.add(terrain);
    }
    state = state.copyWith(selectedTerrains: current);
  }

  void setMaxDuration(int? days) {
    if (days == null) {
      state = state.copyWith(clearMaxDuration: true);
    } else {
      state = state.copyWith(maxDurationDays: days);
    }
  }

  void resetFilters() {
    state = const MapFilterState();
  }
}

final mapFilterProvider = NotifierProvider<MapFilterNotifier, MapFilterState>(() {
  return MapFilterNotifier();
});

/// Riverpod Provider combining ActivitySelector selections, Selected State filter, MapFilterState, and Destinations.
final filteredDestinationsProvider = Provider<List<Destination>>((ref) {
  final asyncDestinations = ref.watch(allDestinationsProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedSubTypes = ref.watch(selectedSubTypesProvider);
  final selectedActivities = ref.watch(selectedActivitiesProvider);
  final selectedState = ref.watch(selectedStateProvider);
  final filterState = ref.watch(mapFilterProvider);

  final allDestinations = asyncDestinations.asData?.value ?? [];

  return allDestinations.where((destination) {
    // 0. State Filter (from Browse By State)
    if (selectedState != null && selectedState.isNotEmpty) {
      if (destination.state.toLowerCase() != selectedState.toLowerCase()) {
        return false;
      }
    }

    // 1. Primary Category Filter (from ActivitySelector)
    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      final String catId = selectedCategory;
      final bool matchesCategory = switch (catId) {
        'trekking' => destination.category == 'Trekking & Hiking',
        'wildlife' => destination.category == 'Wildlife & Safari Expeditions',
        'cultural' => destination.category == 'Cultural Immersion Trips',
        'wellness' => destination.category == 'Wellness & Relaxation Escapes',
        'road_trip' => destination.category == 'Road Trips',
        _ => destination.category.toLowerCase().contains(catId.toLowerCase()),
      };
      if (!matchesCategory) return false;
    }

    // 2. Sub-Type Filter (if selected in ActivitySelector)
    if (selectedSubTypes.isNotEmpty) {
      if (destination.subType == null || !selectedSubTypes.contains(destination.subType)) {
        return false;
      }
    }

    // 3. Legacy Activity Type Filter (fallback for multi-select)
    if (selectedCategory == null && selectedActivities.isNotEmpty) {
      final matchesActivity = destination.activityTypes
          .any((activityId) => selectedActivities.contains(activityId));
      if (!matchesActivity) return false;
    }

    // 4. Modal Category Filter
    if (filterState.selectedCategories.isNotEmpty) {
      if (!filterState.selectedCategories.contains(destination.category)) {
        return false;
      }
    }

    // 5. Difficulty Level Filter
    if (filterState.selectedDifficulties.isNotEmpty) {
      if (destination.difficulty == null || !filterState.selectedDifficulties.contains(destination.difficulty)) {
        return false;
      }
    }

    // 6. Terrain Type Filter
    if (filterState.selectedTerrains.isNotEmpty) {
      if (!filterState.selectedTerrains.contains(destination.terrainType)) {
        return false;
      }
    }

    // 7. Duration Filter
    if (filterState.maxDurationDays != null) {
      if (destination.durationDays != null && destination.durationDays! > filterState.maxDurationDays!) {
        return false;
      }
    }

    return true;
  }).toList();
});
