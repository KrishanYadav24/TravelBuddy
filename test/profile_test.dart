import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_buddy/models/community.dart';
import 'package:travel_buddy/features/profile/providers/profile_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Feature Unit Tests', () {
    test('Initial UserProfile has expected default values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final profile = container.read(userProfileProvider);
      expect(profile.name, equals('Explorer User'));
      expect(profile.email, equals('explorer@travelbuddy.in'));
      expect(profile.fitnessLevel, equals(FitnessLevel.intermediate));
      expect(profile.preferredStates, contains('Uttarakhand'));
      expect(profile.notifyWeatherAlerts, isTrue);
      expect(profile.language, equals('English'));
      expect(profile.isDarkMode, isFalse);
    });

    test('updateName changes user display name', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userProfileProvider.notifier);
      notifier.updateName('Aarav Sharma');

      final profile = container.read(userProfileProvider);
      expect(profile.name, equals('Aarav Sharma'));
    });

    test('updateFitnessLevel updates fitness level setting', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userProfileProvider.notifier);
      notifier.updateFitnessLevel(FitnessLevel.advanced);

      final profile = container.read(userProfileProvider);
      expect(profile.fitnessLevel, equals(FitnessLevel.advanced));
    });

    test('togglePreferredState adds and removes states from preferences', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userProfileProvider.notifier);

      // Add Ladakh
      notifier.togglePreferredState('Ladakh');
      var profile = container.read(userProfileProvider);
      expect(profile.preferredStates, contains('Ladakh'));

      // Remove Uttarakhand
      notifier.togglePreferredState('Uttarakhand');
      profile = container.read(userProfileProvider);
      expect(profile.preferredStates, isNot(contains('Uttarakhand')));
    });

    test('Notification toggles update respective flags', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userProfileProvider.notifier);

      notifier.toggleWeatherAlerts(false);
      notifier.toggleNewDestinations(false);
      notifier.toggleCommunityActivity(false);

      final profile = container.read(userProfileProvider);
      expect(profile.notifyWeatherAlerts, isFalse);
      expect(profile.notifyNewDestinations, isFalse);
      expect(profile.notifyCommunityActivity, isFalse);
    });

    test('Language and Dark Mode toggles persist correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userProfileProvider.notifier);

      notifier.updateLanguage('Hindi');
      notifier.toggleDarkMode(true);

      final profile = container.read(userProfileProvider);
      expect(profile.language, equals('Hindi'));
      expect(profile.isDarkMode, isTrue);
    });

    test('resetProfile restores default profile values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(userProfileProvider.notifier);

      notifier.updateName('Temporary User');
      notifier.updateFitnessLevel(FitnessLevel.beginner);

      notifier.resetProfile();
      final profile = container.read(userProfileProvider);
      expect(profile.name, equals('Explorer User'));
      expect(profile.fitnessLevel, equals(FitnessLevel.intermediate));
    });
  });
}
