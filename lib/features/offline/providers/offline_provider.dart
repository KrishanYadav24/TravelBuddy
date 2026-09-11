import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../itinerary/providers/itinerary_provider.dart';

enum DownloadStatus {
  notDownloaded,
  downloading,
  downloaded,
}

class OfflineRegion {
  final String id;
  final String title;
  final String subtitle;
  final double estimatedSizeMb;
  final DownloadStatus status;
  final double downloadProgress; // 0.0 to 1.0
  final bool isTripDerived;
  final String? tripId;

  const OfflineRegion({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.estimatedSizeMb,
    this.status = DownloadStatus.notDownloaded,
    this.downloadProgress = 0.0,
    this.isTripDerived = false,
    this.tripId,
  });

  OfflineRegion copyWith({
    String? id,
    String? title,
    String? subtitle,
    double? estimatedSizeMb,
    DownloadStatus? status,
    double? downloadProgress,
    bool? isTripDerived,
    String? tripId,
  }) {
    return OfflineRegion(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      estimatedSizeMb: estimatedSizeMb ?? this.estimatedSizeMb,
      status: status ?? this.status,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isTripDerived: isTripDerived ?? this.isTripDerived,
      tripId: tripId ?? this.tripId,
    );
  }
}

/// State Notifier managing offline map regions and download simulations.
class OfflineNotifier extends Notifier<List<OfflineRegion>> {
  final Map<String, Timer> _activeTimers = {};

  @override
  List<OfflineRegion> build() {
    // Watch itineraryProvider to auto-generate trip region packages
    final itineraries = ref.watch(itineraryProvider);

    final tripRegions = itineraries.map((trip) {
      final size = (trip.stops.length * 15.0).clamp(25.0, 150.0);
      return OfflineRegion(
        id: 'trip_${trip.id}',
        title: '${trip.name} Offline Maps',
        subtitle: '${trip.stops.length} trail stops saved',
        estimatedSizeMb: size,
        isTripDerived: true,
        tripId: trip.id,
      );
    }).toList();

    // Default regional preset packs
    final presetRegions = const [
      OfflineRegion(
        id: 'pack_himachal',
        title: 'Himachal Pradesh Alpine Pack',
        subtitle: 'Kedarkantha, Spiti Valley, Parvati Trail',
        estimatedSizeMb: 120.0,
      ),
      OfflineRegion(
        id: 'pack_uttarakhand',
        title: 'Uttarakhand Valley & Peaks Pack',
        subtitle: 'Valley of Flowers, Chopta, Har Ki Dun',
        estimatedSizeMb: 95.0,
      ),
      OfflineRegion(
        id: 'pack_ladakh',
        title: 'Ladakh & Zanskar Off-Grid Pack',
        subtitle: 'Markha Valley, Pangong, Nubra Pass',
        estimatedSizeMb: 185.0,
      ),
      OfflineRegion(
        id: 'pack_south',
        title: 'Western Ghats & Nilgiris Pack',
        subtitle: 'Munnar, Hampi, Jog Falls, Wayanad',
        estimatedSizeMb: 110.0,
      ),
    ];

    // Maintain existing state statuses if rebuild triggered by trip update
    final previousState = stateOrNull ?? [];

    final merged = <OfflineRegion>[];
    for (var r in [...tripRegions, ...presetRegions]) {
      final existing = previousState.firstWhere(
        (p) => p.id == r.id,
        orElse: () => r,
      );
      merged.add(existing);
    }

    return merged;
  }

  /// Start simulated download with 0.1s tick interval (~3 seconds total)
  void startDownload(String regionId) {
    final index = state.indexWhere((r) => r.id == regionId);
    if (index == -1) return;

    // Cancel existing timer if any
    _activeTimers[regionId]?.cancel();

    // Set status to downloading with 0% progress
    final updated = List<OfflineRegion>.from(state);
    updated[index] = updated[index].copyWith(
      status: DownloadStatus.downloading,
      downloadProgress: 0.05,
    );
    state = updated;

    const tickInterval = Duration(milliseconds: 100);
    const totalTicks = 30; // 3.0 seconds total
    int currentTick = 0;

    _activeTimers[regionId] = Timer.periodic(tickInterval, (timer) {
      currentTick++;
      final progress = (currentTick / totalTicks).clamp(0.0, 1.0);

      final idx = state.indexWhere((r) => r.id == regionId);
      if (idx == -1) {
        timer.cancel();
        return;
      }

      final curList = List<OfflineRegion>.from(state);
      if (currentTick >= totalTicks) {
        timer.cancel();
        _activeTimers.remove(regionId);
        curList[idx] = curList[idx].copyWith(
          status: DownloadStatus.downloaded,
          downloadProgress: 1.0,
        );
      } else {
        curList[idx] = curList[idx].copyWith(
          downloadProgress: progress,
        );
      }
      state = curList;
    });
  }

  /// Cancel an ongoing download
  void cancelDownload(String regionId) {
    _activeTimers[regionId]?.cancel();
    _activeTimers.remove(regionId);

    final idx = state.indexWhere((r) => r.id == regionId);
    if (idx != -1) {
      final curList = List<OfflineRegion>.from(state);
      curList[idx] = curList[idx].copyWith(
        status: DownloadStatus.notDownloaded,
        downloadProgress: 0.0,
      );
      state = curList;
    }
  }

  /// Delete a downloaded map region
  void deleteDownload(String regionId) {
    _activeTimers[regionId]?.cancel();
    _activeTimers.remove(regionId);

    final idx = state.indexWhere((r) => r.id == regionId);
    if (idx != -1) {
      final curList = List<OfflineRegion>.from(state);
      curList[idx] = curList[idx].copyWith(
        status: DownloadStatus.notDownloaded,
        downloadProgress: 0.0,
      );
      state = curList;
    }
  }

  /// Add a custom downloaded region
  void addCustomRegion(String title, double sizeMb) {
    final customId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final newRegion = OfflineRegion(
      id: customId,
      title: title,
      subtitle: 'Custom Bounding Area',
      estimatedSizeMb: sizeMb,
    );

    state = [...state, newRegion];
    startDownload(customId);
  }

  /// Calculate total storage used in MB across all downloaded regions
  double get totalStorageUsedMb {
    double total = 0.0;
    for (var r in state) {
      if (r.status == DownloadStatus.downloaded) {
        total += r.estimatedSizeMb;
      }
    }
    return total;
  }
}

final offlineProvider = NotifierProvider<OfflineNotifier, List<OfflineRegion>>(() {
  return OfflineNotifier();
});
