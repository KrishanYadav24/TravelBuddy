import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_buddy/features/itinerary/providers/itinerary_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ItineraryNotifier Unit Tests', () {
    test('Initial itinerary list is non-empty with default sample trip', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final itineraries = container.read(itineraryProvider);
      expect(itineraries, isNotEmpty);
      expect(itineraries.first.name, equals('Himalayan Summer Expedition'));
    });

    test('createItinerary creates new named trip', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(itineraryProvider.notifier);
      final newTrip = notifier.createItinerary('Goa Beach Tour');

      expect(newTrip.name, equals('Goa Beach Tour'));
      final itineraries = container.read(itineraryProvider);
      expect(itineraries.any((t) => t.name == 'Goa Beach Tour'), isTrue);
    });

    test('addStop, removeStop, reorderStops, and updateStopDate work correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(itineraryProvider.notifier);
      final trip = notifier.createItinerary('South India Circuit');
      final tripId = trip.id;

      // 1. Add stops
      notifier.addStop(tripId, 'hampi');
      notifier.addStop(tripId, 'jog_falls');
      notifier.addStop(tripId, 'munnar');

      var updated = container.read(itineraryProvider).firstWhere((t) => t.id == tripId);
      expect(updated.stops.length, equals(3));
      expect(updated.stops[0].destinationId, equals('hampi'));
      expect(updated.stops[1].destinationId, equals('jog_falls'));
      expect(updated.stops[2].destinationId, equals('munnar'));

      // 2. Reorder stops
      notifier.reorderStops(tripId, 2, 0); // Move munnar to top
      updated = container.read(itineraryProvider).firstWhere((t) => t.id == tripId);
      expect(updated.stops[0].destinationId, equals('munnar'));
      expect(updated.stops[1].destinationId, equals('hampi'));
      expect(updated.stops[2].destinationId, equals('jog_falls'));

      // 3. Update stop date
      final testDate = DateTime(2026, 7, 15);
      notifier.updateStopDate(tripId, 'munnar', testDate);
      updated = container.read(itineraryProvider).firstWhere((t) => t.id == tripId);
      expect(updated.stops[0].plannedDate, equals(testDate));

      // 4. Remove stop
      notifier.removeStop(tripId, 'hampi');
      updated = container.read(itineraryProvider).firstWhere((t) => t.id == tripId);
      expect(updated.stops.length, equals(2));
      expect(updated.stops.any((s) => s.destinationId == 'hampi'), isFalse);
    });

    test('deleteItinerary removes trip completely', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(itineraryProvider.notifier);
      final trip = notifier.createItinerary('Temporary Trip');

      notifier.deleteItinerary(trip.id);
      final itineraries = container.read(itineraryProvider);
      expect(itineraries.any((t) => t.id == trip.id), isFalse);
    });
  });
}
