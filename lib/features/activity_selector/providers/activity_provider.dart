import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod Notifier managing the set of selected activity IDs.
class SelectedActivitiesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return <String>{};
  }

  /// Toggle selection state of an activity ID.
  void toggleActivity(String id) {
    if (state.contains(id)) {
      state = Set<String>.from(state)..remove(id);
    } else {
      state = Set<String>.from(state)..add(id);
    }
  }

  /// Clear all selected activity IDs.
  void clearSelection() {
    state = <String>{};
  }
}

final selectedActivitiesProvider =
    NotifierProvider<SelectedActivitiesNotifier, Set<String>>(() {
  return SelectedActivitiesNotifier();
});
