import '../core/config/env_config.dart';
import '../models/destination.dart';
import 'destination_repository.dart';

class RemoteDestinationRepository implements DestinationRepository {
  final DestinationRepository _localFallbackRepository;

  RemoteDestinationRepository({DestinationRepository? fallback})
      : _localFallbackRepository = fallback ?? MockDestinationRepository();

  @override
  Future<List<Destination>> getDestinations() async {
    if (!EnvConfig.useMockData) {
      try {
        // Firestore Remote Fetching Integration Point
        // final snapshot = await FirebaseFirestore.instance.collection('destinations').get();
        // return snapshot.docs.map((doc) => Destination.fromMap(doc.data())).toList();
      } catch (_) {
        // Fallback to local seed data if network call fails
      }
    }
    return _localFallbackRepository.getDestinations();
  }

  @override
  Future<Destination?> getDestinationById(String id) async {
    final destinations = await getDestinations();
    try {
      return destinations.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Destination>> searchDestinations(String query) async {
    final destinations = await getDestinations();
    final lower = query.toLowerCase();
    return destinations.where((d) {
      return d.name.toLowerCase().contains(lower) ||
          d.state.toLowerCase().contains(lower) ||
          d.region.toLowerCase().contains(lower);
    }).toList();
  }
}
