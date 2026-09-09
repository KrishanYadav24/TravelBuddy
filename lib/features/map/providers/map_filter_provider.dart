import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/destination.dart';
import '../../../services/destination_repository.dart';
import '../../activity_selector/providers/activity_provider.dart';

/// State object representing active map filters.
class MapFilterState {
  final Set<DifficultyLevel> selectedDifficulties;
  final Set<String> selectedTerrains;
  final int? maxDurationDays;

  const MapFilterState({
    this.selectedDifficulties = const {},
    this.selectedTerrains = const {},
    this.maxDurationDays,
  });

  MapFilterState copyWith({
    Set<DifficultyLevel>? selectedDifficulties,
    Set<String>? selectedTerrains,
    int? maxDurationDays,
    bool clearMaxDuration = false,
  }) {
    return MapFilterState(
      selectedDifficulties: selectedDifficulties ?? this.selectedDifficulties,
      selectedTerrains: selectedTerrains ?? this.selectedTerrains,
      maxDurationDays: clearMaxDuration ? null : (maxDurationDays ?? this.maxDurationDays),
    );
  }

  bool get hasActiveFilters =>
      selectedDifficulties.isNotEmpty ||
      selectedTerrains.isNotEmpty ||
      maxDurationDays != null;
}

class MapFilterNotifier extends Notifier<MapFilterState> {
  @override
  MapFilterState build() {
    return const MapFilterState();
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

/// Riverpod Provider combining ActivitySelector selections, MapFilterState, and Destinations.
final filteredDestinationsProvider = Provider<List<Destination>>((ref) {
  final asyncDestinations = ref.watch(allDestinationsProvider);
  final selectedActivities = ref.watch(selectedActivitiesProvider);
  final filterState = ref.watch(mapFilterProvider);

  final allDestinations = asyncDestinations.asData?.value ?? [];

  return allDestinations.where((destination) {
    // 1. Activity Type Filter (if none selected, show all)
    if (selectedActivities.isNotEmpty) {
      final matchesActivity = destination.activityTypes
          .any((activityId) => selectedActivities.contains(activityId));
      if (!matchesActivity) return false;
    }

    // 2. Difficulty Level Filter
    if (filterState.selectedDifficulties.isNotEmpty) {
      if (!filterState.selectedDifficulties.contains(destination.difficulty)) {
        return false;
      }
    }

    // 3. Terrain Type Filter
    if (filterState.selectedTerrains.isNotEmpty) {
      if (!filterState.selectedTerrains.contains(destination.terrainType)) {
        return false;
      }
    }

    // 4. Duration Filter
    if (filterState.maxDurationDays != null) {
      if (destination.durationDays > filterState.maxDurationDays!) {
        return false;
      }
    }

    return true;
  }).toList();
});
