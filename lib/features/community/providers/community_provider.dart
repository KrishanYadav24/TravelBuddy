import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/community.dart';
import '../../../services/community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return MockCommunityRepository();
});

/// Filter State Model for Buddy Feed
class BuddyFeedFilter {
  final String? stateFilter;
  final String? activityFilter;
  final FitnessLevel? fitnessFilter;

  const BuddyFeedFilter({
    this.stateFilter,
    this.activityFilter,
    this.fitnessFilter,
  });

  BuddyFeedFilter copyWith({
    String? stateFilter,
    String? activityFilter,
    FitnessLevel? fitnessFilter,
    bool clearState = false,
    bool clearActivity = false,
    bool clearFitness = false,
  }) {
    return BuddyFeedFilter(
      stateFilter: clearState ? null : (stateFilter ?? this.stateFilter),
      activityFilter: clearActivity ? null : (activityFilter ?? this.activityFilter),
      fitnessFilter: clearFitness ? null : (fitnessFilter ?? this.fitnessFilter),
    );
  }
}

class BuddyFilterNotifier extends Notifier<BuddyFeedFilter> {
  @override
  BuddyFeedFilter build() => const BuddyFeedFilter();

  void updateFilter(BuddyFeedFilter filter) {
    state = filter;
  }

  void reset() {
    state = const BuddyFeedFilter();
  }
}

final buddyFilterProvider = NotifierProvider<BuddyFilterNotifier, BuddyFeedFilter>(() {
  return BuddyFilterNotifier();
});

/// Notifier managing Buddy Posts Feed
class BuddyPostsNotifier extends Notifier<AsyncValue<List<BuddyPost>>> {
  @override
  AsyncValue<List<BuddyPost>> build() {
    _loadInitialPosts();
    return const AsyncValue.loading();
  }

  Future<void> _loadInitialPosts() async {
    try {
      final repo = ref.read(communityRepositoryProvider);
      final posts = await repo.fetchBuddyPosts();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void toggleInterested(String postId) {
    state.whenData((posts) {
      final updated = posts.map((p) {
        if (p.id == postId) {
          final newStatus = !p.isInterested;
          final newCount = newStatus ? p.interestedCount + 1 : p.interestedCount - 1;
          return p.copyWith(
            isInterested: newStatus,
            interestedCount: newCount < 0 ? 0 : newCount,
          );
        }
        return p;
      }).toList();

      state = AsyncValue.data(updated);
    });
  }

  void addPost({
    required String locationName,
    String? stateName,
    String? activityType,
    required DateTime plannedDate,
    required FitnessLevel fitnessLevel,
    required String note,
    required String userName,
  }) {
    final newPost = BuddyPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_current',
      userName: userName,
      locationName: locationName,
      stateName: stateName,
      activityType: activityType,
      plannedDate: plannedDate,
      fitnessLevel: fitnessLevel,
      note: note,
      createdAt: DateTime.now(),
      interestedCount: 1,
      isInterested: true,
    );

    state.whenData((posts) {
      state = AsyncValue.data([newPost, ...posts]);
    });
  }
}

final buddyPostsProvider = NotifierProvider<BuddyPostsNotifier, AsyncValue<List<BuddyPost>>>(() {
  return BuddyPostsNotifier();
});

/// Filtered Buddy Posts Provider
final filteredBuddyPostsProvider = Provider<AsyncValue<List<BuddyPost>>>((ref) {
  final rawPosts = ref.watch(buddyPostsProvider);
  final filter = ref.watch(buddyFilterProvider);

  return rawPosts.whenData((posts) {
    return posts.where((p) {
      if (filter.stateFilter != null && filter.stateFilter!.isNotEmpty) {
        if (p.stateName?.toLowerCase() != filter.stateFilter!.toLowerCase()) {
          return false;
        }
      }
      if (filter.activityFilter != null && filter.activityFilter!.isNotEmpty) {
        if (p.activityType?.toLowerCase() != filter.activityFilter!.toLowerCase()) {
          return false;
        }
      }
      if (filter.fitnessFilter != null) {
        if (p.fitnessLevel != filter.fitnessFilter) {
          return false;
        }
      }
      return true;
    }).toList();
  });
});

/// Notifier managing Community Q&A
class CommunityQANotifier extends Notifier<AsyncValue<List<CommunityQuestion>>> {
  @override
  AsyncValue<List<CommunityQuestion>> build() {
    _loadInitialQuestions();
    return const AsyncValue.loading();
  }

  Future<void> _loadInitialQuestions() async {
    try {
      final repo = ref.read(communityRepositoryProvider);
      final questions = await repo.fetchQuestions();
      state = AsyncValue.data(questions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addQuestion({
    required String userName,
    required String destinationName,
    required String questionText,
  }) {
    final newQ = CommunityQuestion(
      id: 'q_${DateTime.now().millisecondsSinceEpoch}',
      userName: userName,
      destinationName: destinationName,
      questionText: questionText,
      createdAt: DateTime.now(),
      answers: const [],
    );

    state.whenData((questions) {
      state = AsyncValue.data([newQ, ...questions]);
    });
  }

  void addAnswer(String questionId, String authorName, String answerText) {
    state.whenData((questions) {
      final updated = questions.map((q) {
        if (q.id == questionId) {
          final newAns = CommunityAnswer(
            authorName: authorName,
            answerText: answerText,
            createdAt: DateTime.now(),
          );
          return q.copyWith(answers: [...q.answers, newAns]);
        }
        return q;
      }).toList();

      state = AsyncValue.data(updated);
    });
  }
}

final communityQAProvider = NotifierProvider<CommunityQANotifier, AsyncValue<List<CommunityQuestion>>>(() {
  return CommunityQANotifier();
});
