import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String kWishlistBoxName = 'wishlist_box';

class WishlistNotifier extends Notifier<Set<String>> {
  Box<String>? _box;

  @override
  Set<String> build() {
    _initHive();
    return _loadFromHive();
  }

  void _initHive() {
    if (Hive.isBoxOpen(kWishlistBoxName)) {
      _box = Hive.box<String>(kWishlistBoxName);
    }
  }

  Set<String> _loadFromHive() {
    if (_box != null && _box!.isOpen) {
      return _box!.values.toSet();
    }
    return {};
  }

  bool isWishlisted(String destinationId) {
    return state.contains(destinationId);
  }

  void toggleWishlist(String destinationId) {
    final updated = Set<String>.from(state);
    if (updated.contains(destinationId)) {
      updated.remove(destinationId);
      _removeFromHive(destinationId);
    } else {
      updated.add(destinationId);
      _addToHive(destinationId);
    }
    state = updated;
  }

  void addWishlist(String destinationId) {
    if (!state.contains(destinationId)) {
      final updated = Set<String>.from(state)..add(destinationId);
      _addToHive(destinationId);
      state = updated;
    }
  }

  void removeWishlist(String destinationId) {
    if (state.contains(destinationId)) {
      final updated = Set<String>.from(state)..remove(destinationId);
      _removeFromHive(destinationId);
      state = updated;
    }
  }

  void _addToHive(String id) {
    _box?.put(id, id);
  }

  void _removeFromHive(String id) {
    _box?.delete(id);
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, Set<String>>(() {
  return WishlistNotifier();
});
