import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_buddy/features/offline/providers/offline_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfflineNotifier Unit Tests', () {
    test('Initial offline region list contains default preset packs', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final regions = container.read(offlineProvider);
      expect(regions, isNotEmpty);
      expect(regions.any((r) => r.id == 'pack_himachal'), isTrue);
      expect(container.read(offlineProvider.notifier).totalStorageUsedMb, equals(0.0));
    });

    test('startDownload changes status to downloading and eventually completes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(offlineProvider.notifier);

      notifier.startDownload('pack_himachal');
      var regions = container.read(offlineProvider);
      var himachal = regions.firstWhere((r) => r.id == 'pack_himachal');
      expect(himachal.status, equals(DownloadStatus.downloading));

      // Wait for timer ticks (~3.1 seconds)
      await Future.delayed(const Duration(milliseconds: 3200));

      regions = container.read(offlineProvider);
      himachal = regions.firstWhere((r) => r.id == 'pack_himachal');
      expect(himachal.status, equals(DownloadStatus.downloaded));
      expect(himachal.downloadProgress, equals(1.0));
      expect(notifier.totalStorageUsedMb, equals(120.0));
    });

    test('cancelDownload resets region status back to notDownloaded', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(offlineProvider.notifier);
      notifier.startDownload('pack_uttarakhand');

      var regions = container.read(offlineProvider);
      var ut = regions.firstWhere((r) => r.id == 'pack_uttarakhand');
      expect(ut.status, equals(DownloadStatus.downloading));

      notifier.cancelDownload('pack_uttarakhand');
      regions = container.read(offlineProvider);
      ut = regions.firstWhere((r) => r.id == 'pack_uttarakhand');
      expect(ut.status, equals(DownloadStatus.notDownloaded));
      expect(ut.downloadProgress, equals(0.0));
    });

    test('deleteDownload clears downloaded state and updates storage calculation', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(offlineProvider.notifier);
      notifier.startDownload('pack_uttarakhand');

      await Future.delayed(const Duration(milliseconds: 3200));
      expect(notifier.totalStorageUsedMb, equals(95.0));

      notifier.deleteDownload('pack_uttarakhand');
      expect(notifier.totalStorageUsedMb, equals(0.0));
      final ut = container.read(offlineProvider).firstWhere((r) => r.id == 'pack_uttarakhand');
      expect(ut.status, equals(DownloadStatus.notDownloaded));
    });

    test('addCustomRegion creates new custom region and starts download', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(offlineProvider.notifier);
      notifier.addCustomRegion('Valley Trekking Area', 75.0);

      final regions = container.read(offlineProvider);
      expect(regions.any((r) => r.title == 'Valley Trekking Area'), isTrue);
      final custom = regions.firstWhere((r) => r.title == 'Valley Trekking Area');
      expect(custom.status, equals(DownloadStatus.downloading));
      expect(custom.estimatedSizeMb, equals(75.0));
    });
  });
}
