import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/itinerary.dart';

const String kItinerariesBoxName = 'itineraries_box';

class ItineraryNotifier extends Notifier<List<Itinerary>> {
  Box<String>? _box;

  @override
  List<Itinerary> build() {
    _initHive();
    final loaded = _loadFromHive();
    if (loaded.isEmpty) {
      // Create a default sample trip if none exist yet
      final sample = Itinerary(
        id: 'sample_trip_1',
        name: 'Himalayan Summer Expedition',
        stops: const [
          ItineraryStop(destinationId: 'kedarkantha', order: 0),
          ItineraryStop(destinationId: 'chopta_tungnath', order: 1),
          ItineraryStop(destinationId: 'valley_of_flowers', order: 2),
        ],
        createdAt: DateTime.now(),
      );
      _box?.put(sample.id, json.encode(sample.toMap()));
      return [sample];
    }
    return loaded;
  }

  void _initHive() {
    if (Hive.isBoxOpen(kItinerariesBoxName)) {
      _box = Hive.box<String>(kItinerariesBoxName);
    }
  }

  List<Itinerary> _loadFromHive() {
    if (_box != null && _box!.isOpen) {
      final items = <Itinerary>[];
      for (var val in _box!.values) {
        try {
          final map = json.decode(val) as Map<String, dynamic>;
          items.add(Itinerary.fromMap(map));
        } catch (_) {}
      }
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    }
    return [];
  }

  Itinerary createItinerary(String name) {
    final newTrip = Itinerary(
      id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Untitled Trip' : name.trim(),
      stops: [],
      createdAt: DateTime.now(),
    );
    _saveToHive(newTrip);
    state = [newTrip, ...state];
    return newTrip;
  }

  void deleteItinerary(String id) {
    _removeFromHive(id);
    state = state.where((t) => t.id != id).toList();
  }

  void addStop(String itineraryId, String destinationId, {DateTime? plannedDate}) {
    final updated = state.map((trip) {
      if (trip.id == itineraryId) {
        // Prevent duplicate stops
        if (trip.stops.any((s) => s.destinationId == destinationId)) {
          return trip;
        }
        final newStop = ItineraryStop(
          destinationId: destinationId,
          order: trip.stops.length,
          plannedDate: plannedDate,
        );
        final newStops = [...trip.stops, newStop];
        final updatedTrip = trip.copyWith(stops: newStops);
        _saveToHive(updatedTrip);
        return updatedTrip;
      }
      return trip;
    }).toList();
    state = updated;
  }

  void removeStop(String itineraryId, String destinationId) {
    final updated = state.map((trip) {
      if (trip.id == itineraryId) {
        final filtered = trip.stops.where((s) => s.destinationId != destinationId).toList();
        // Re-index stop orders
        final reindexed = List<ItineraryStop>.generate(
          filtered.length,
          (i) => filtered[i].copyWith(order: i),
        );
        final updatedTrip = trip.copyWith(stops: reindexed);
        _saveToHive(updatedTrip);
        return updatedTrip;
      }
      return trip;
    }).toList();
    state = updated;
  }

  void reorderStops(String itineraryId, int oldIndex, int newIndex) {
    final updated = state.map((trip) {
      if (trip.id == itineraryId) {
        final stops = List<ItineraryStop>.from(trip.stops);
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final item = stops.removeAt(oldIndex);
        stops.insert(newIndex, item);

        final reindexed = List<ItineraryStop>.generate(
          stops.length,
          (i) => stops[i].copyWith(order: i),
        );
        final updatedTrip = trip.copyWith(stops: reindexed);
        _saveToHive(updatedTrip);
        return updatedTrip;
      }
      return trip;
    }).toList();
    state = updated;
  }

  void updateStopDate(String itineraryId, String destinationId, DateTime? date) {
    final updated = state.map((trip) {
      if (trip.id == itineraryId) {
        final stops = trip.stops.map((stop) {
          if (stop.destinationId == destinationId) {
            return stop.copyWith(plannedDate: date);
          }
          return stop;
        }).toList();
        final updatedTrip = trip.copyWith(stops: stops);
        _saveToHive(updatedTrip);
        return updatedTrip;
      }
      return trip;
    }).toList();
    state = updated;
  }

  void _saveToHive(Itinerary itinerary) {
    _box?.put(itinerary.id, json.encode(itinerary.toMap()));
  }

  void _removeFromHive(String id) {
    _box?.delete(id);
  }
}

final itineraryProvider = NotifierProvider<ItineraryNotifier, List<Itinerary>>(() {
  return ItineraryNotifier();
});
