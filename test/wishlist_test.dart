import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_buddy/features/wishlist/providers/wishlist_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WishlistNotifier Unit Tests', () {
    test('Initial wishlist state is empty when Hive box is uninitialized in pure unit tests', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final wishlist = container.read(wishlistProvider);
      expect(wishlist, isEmpty);
    });

    test('addWishlist and removeWishlist modify state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);

      notifier.addWishlist('kedarkantha');
      expect(container.read(wishlistProvider), contains('kedarkantha'));

      notifier.removeWishlist('kedarkantha');
      expect(container.read(wishlistProvider), isNot(contains('kedarkantha')));
    });

    test('toggleWishlist toggles destination presence in state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);

      notifier.toggleWishlist('spiti_valley');
      expect(container.read(wishlistProvider), contains('spiti_valley'));

      notifier.toggleWishlist('spiti_valley');
      expect(container.read(wishlistProvider), isNot(contains('spiti_valley')));
    });
  });
}
