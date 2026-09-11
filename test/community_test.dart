import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_buddy/models/community.dart';
import 'package:travel_buddy/features/community/providers/community_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Community Feature Unit Tests', () {
    test('Initial buddy posts load correctly from MockCommunityRepository', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger build and wait for async loading to resolve to data
      container.read(buddyPostsProvider);
      await Future.delayed(Duration.zero);

      final postsAsync = container.read(buddyPostsProvider);
      expect(postsAsync.hasValue, isTrue);
      final posts = postsAsync.value!;
      expect(posts.length, greaterThanOrEqualTo(6));
      expect(posts.any((p) => p.locationName.contains('Kedarkantha')), isTrue);
    });

    test('toggleInterested updates interested count and boolean status', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(buddyPostsProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(buddyPostsProvider.notifier);

      final initial = container.read(buddyPostsProvider).value!.firstWhere((p) => p.id == 'post_1');
      final initialCount = initial.interestedCount;
      expect(initial.isInterested, isFalse);

      notifier.toggleInterested('post_1');
      var updated = container.read(buddyPostsProvider).value!.firstWhere((p) => p.id == 'post_1');
      expect(updated.isInterested, isTrue);
      expect(updated.interestedCount, equals(initialCount + 1));

      notifier.toggleInterested('post_1');
      updated = container.read(buddyPostsProvider).value!.firstWhere((p) => p.id == 'post_1');
      expect(updated.isInterested, isFalse);
      expect(updated.interestedCount, equals(initialCount));
    });

    test('addPost prepends a new buddy post to the state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(buddyPostsProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(buddyPostsProvider.notifier);

      notifier.addPost(
        locationName: 'Spiti Pass Trek',
        stateName: 'Himachal Pradesh',
        activityType: 'Trekking',
        plannedDate: DateTime(2026, 12, 1),
        fitnessLevel: FitnessLevel.advanced,
        note: 'Extreme winter trek seeking experienced partners',
        userName: 'Test Explorer',
      );

      final posts = container.read(buddyPostsProvider).value!;
      expect(posts.first.locationName, equals('Spiti Pass Trek'));
      expect(posts.first.userName, equals('Test Explorer'));
      expect(posts.first.isInterested, isTrue);
    });

    test('Filtered buddy posts provider filters by state and fitness level', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(buddyPostsProvider);
      await Future.delayed(Duration.zero);

      refFilter(BuddyFeedFilter f) {
        container.read(buddyFilterProvider.notifier).updateFilter(f);
      }

      refFilter(const BuddyFeedFilter(stateFilter: 'Uttarakhand'));
      var filtered = container.read(filteredBuddyPostsProvider).value!;
      expect(filtered.every((p) => p.stateName == 'Uttarakhand'), isTrue);

      refFilter(const BuddyFeedFilter(fitnessFilter: FitnessLevel.beginner));
      filtered = container.read(filteredBuddyPostsProvider).value!;
      expect(filtered.every((p) => p.fitnessLevel == FitnessLevel.beginner), isTrue);
    });

    test('Community Q&A addQuestion and addAnswer work correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(communityQAProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(communityQAProvider.notifier);

      notifier.addQuestion(
        userName: 'Questioner One',
        destinationName: 'Kedarkantha Summit',
        questionText: 'Is tent rental available at Sankri base village?',
      );

      final questions = container.read(communityQAProvider).value!;
      final newQ = questions.firstWhere((q) => q.questionText.contains('Sankri'));
      expect(newQ.userName, equals('Questioner One'));
      expect(newQ.answers, isEmpty);

      notifier.addAnswer(newQ.id, 'Guide Vikram', 'Yes, multiple rental shops in Sankri provide tents and sleeping bags!');
      final updatedQ = container.read(communityQAProvider).value!.firstWhere((q) => q.id == newQ.id);
      expect(updatedQ.answers.length, equals(1));
      expect(updatedQ.answers.first.authorName, equals('Guide Vikram'));
    });
  });
}
