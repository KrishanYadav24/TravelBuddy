import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/destination.dart';
import '../models/mock_destinations.dart';

/// Repository interface for destination fetching.
/// Swappable for real backend API / Supabase / Firebase repositories.
abstract class DestinationRepository {
  Future<List<Destination>> getDestinations();
  Future<Destination?> getDestinationById(String id);
}

/// Mock implementation returning the 15 static destinations.
class MockDestinationRepository implements DestinationRepository {
  @override
  Future<List<Destination>> getDestinations() async {
    // Simulate brief network latency
    await Future.delayed(const Duration(milliseconds: 100));
    return MockDestinations.items;
  }

  @override
  Future<Destination?> getDestinationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return MockDestinations.items.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Riverpod provider for DestinationRepository.
final destinationRepositoryProvider = Provider<DestinationRepository>((ref) {
  return MockDestinationRepository();
});

/// Riverpod provider fetching all destinations.
final allDestinationsProvider = FutureProvider<List<Destination>>((ref) async {
  final repository = ref.watch(destinationRepositoryProvider);
  return repository.getDestinations();
});
