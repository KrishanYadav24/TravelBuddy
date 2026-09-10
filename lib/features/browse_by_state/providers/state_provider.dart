import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod Notifier managing selected state filter for Map view.
class SelectedStateNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void selectState(String stateName) {
    state = stateName;
  }

  void clearState() {
    state = null;
  }
}

final selectedStateProvider =
    NotifierProvider<SelectedStateNotifier, String?>(() {
  return SelectedStateNotifier();
});
