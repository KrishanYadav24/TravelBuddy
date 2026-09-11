import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy/core/config/env_config.dart';
import 'package:travel_buddy/services/auth_service.dart';
import 'package:travel_buddy/services/notification_service.dart';
import 'package:travel_buddy/services/review_service.dart';
import 'package:travel_buddy/services/weather_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Stage 12 Services & Cloud Integrations Unit Tests', () {
    test('EnvConfig initializes and provides default mock fallback', () async {
      await EnvConfig.init();
      expect(EnvConfig.useMockData, isTrue);
    });

    test('WeatherService returns altitude-adjusted forecast when offline/demo', () async {
      final service = WeatherService();

      // High altitude (3800m)
      final highAlt = await service.getWeather(30.7, 78.4, altitudeMeters: 3800);
      expect(highAlt.isLiveApiData, isFalse);
      expect(highAlt.tempCelsius, lessThan(15.0));
      expect(highAlt.dailyForecasts, hasLength(5));

      // Low altitude (500m)
      final lowAlt = await service.getWeather(28.6, 77.2, altitudeMeters: 500);
      expect(lowAlt.tempCelsius, greaterThan(highAlt.tempCelsius));
    });

    test('AuthService provides active user and handles login', () async {
      final service = AuthService();
      expect(service.currentUser, isNotNull);
      expect(service.currentUser?.displayName, contains('Himalayan'));

      final signedIn = await service.signInWithEmail('trekker@test.com', 'password123');
      expect(signedIn?.email, equals('trekker@test.com'));
    });

    test('ReviewService fetches destination reviews and supports adding new reviews', () async {
      final service = ReviewService();
      final reviews = await service.getReviewsForDestination('kedarkantha');
      expect(reviews, isNotEmpty);

      final added = await service.addReview(
        destinationId: 'kedarkantha',
        userName: 'Pooja',
        rating: 5.0,
        comment: 'Breathtaking sunrise!',
      );
      expect(added.userName, equals('Pooja'));

      final updatedReviews = await service.getReviewsForDestination('kedarkantha');
      expect(updatedReviews.first.userName, equals('Pooja'));
    });

    test('NotificationService manages weather alerts and notification feed', () {
      final service = NotificationService();
      final initialNotifs = service.getNotifications();
      expect(initialNotifs, isNotEmpty);

      service.triggerWeatherAlert(
        tripName: 'Himalaya Summer 2026',
        warningDetails: 'Blizzard warning above 3500m',
      );

      final updated = service.getNotifications();
      expect(updated.first.title, contains('Himalaya Summer 2026'));
      expect(updated.first.body, contains('Blizzard warning'));
    });
  });
}
