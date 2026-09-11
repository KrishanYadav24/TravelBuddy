import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod Notifier managing the selected primary activity category ID.
class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void selectCategory(String? categoryId) {
    if (state == categoryId) {
      state = null; // Toggle off if tapped again
    } else {
      state = categoryId;
    }
  }

  void clearCategory() {
    state = null;
  }
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(() {
  return SelectedCategoryNotifier();
});

/// Riverpod Notifier managing selected activity sub-types.
class SelectedSubTypesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return <String>{};
  }

  void toggleSubType(String subType) {
    if (state.contains(subType)) {
      state = Set<String>.from(state)..remove(subType);
    } else {
      state = Set<String>.from(state)..add(subType);
    }
  }

  void clearSubTypes() {
    state = <String>{};
  }
}

final selectedSubTypesProvider =
    NotifierProvider<SelectedSubTypesNotifier, Set<String>>(() {
  return SelectedSubTypesNotifier();
});

/// Riverpod Notifier managing legacy/compatibility set of selected activity IDs.
class SelectedActivitiesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return <String>{};
  }

  void toggleActivity(String id) {
    if (state.contains(id)) {
      state = Set<String>.from(state)..remove(id);
    } else {
      state = Set<String>.from(state)..add(id);
    }
  }

  void clearSelection() {
    state = <String>{};
  }
}

final selectedActivitiesProvider =
    NotifierProvider<SelectedActivitiesNotifier, Set<String>>(() {
  return SelectedActivitiesNotifier();
});
