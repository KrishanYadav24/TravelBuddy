import '../models/community.dart';

abstract class CommunityRepository {
  Future<List<BuddyPost>> fetchBuddyPosts();
  Future<List<CommunityQuestion>> fetchQuestions();
}

class MockCommunityRepository implements CommunityRepository {
  @override
  Future<List<BuddyPost>> fetchBuddyPosts() async {
    return [
      BuddyPost(
        id: 'post_1',
        userId: 'user_aarav',
        userName: 'Aarav Sharma',
        locationName: 'Kedarkantha Summit Trek',
        stateName: 'Uttarakhand',
        activityType: 'Trekking',
        plannedDate: DateTime(2026, 10, 15),
        fitnessLevel: FitnessLevel.intermediate,
        note: 'Planning a 4-day summit attempt. Looking for 2-3 trek buddies to share camp expenses and guide fees!',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        interestedCount: 5,
        isInterested: false,
      ),
      BuddyPost(
        id: 'post_2',
        userId: 'user_ananya',
        userName: 'Ananya Roy',
        locationName: 'Valley of Flowers Trail',
        stateName: 'Uttarakhand',
        activityType: 'Trekking',
        plannedDate: DateTime(2026, 9, 28),
        fitnessLevel: FitnessLevel.beginner,
        note: 'Leisurely flora photography trek! Seeking friendly co-travelers who enjoy slow-paced nature walks.',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        interestedCount: 8,
        isInterested: true,
      ),
      BuddyPost(
        id: 'post_3',
        userId: 'user_rohan',
        userName: 'Rohan Gupta',
        locationName: 'Spiti Valley Circuit',
        stateName: 'Himachal Pradesh',
        activityType: 'Motorcycling',
        plannedDate: DateTime(2026, 10, 5),
        fitnessLevel: FitnessLevel.advanced,
        note: 'Riding Himalayan bike through Kaza and Kunzum Pass. Looking for experienced riders to join the convoy.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        interestedCount: 12,
        isInterested: false,
      ),
      BuddyPost(
        id: 'post_4',
        userId: 'user_priya',
        userName: 'Priya Iyer',
        locationName: 'Hampi Boulder Bouldering',
        stateName: 'Karnataka',
        activityType: 'Rock Climbing',
        plannedDate: DateTime(2026, 11, 10),
        fitnessLevel: FitnessLevel.intermediate,
        note: 'Weekend bouldering trip across Virupaksha ruins. Need a crash pad partner!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        interestedCount: 3,
        isInterested: false,
      ),
      BuddyPost(
        id: 'post_5',
        userId: 'user_kabir',
        userName: 'Kabir Mehta',
        locationName: 'Chopta & Chandrashila',
        stateName: 'Uttarakhand',
        activityType: 'Trekking',
        plannedDate: DateTime(2026, 10, 20),
        fitnessLevel: FitnessLevel.beginner,
        note: 'Sunrise hike to Tungnath temple & Chandrashila peak. Beginner friendly!',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        interestedCount: 7,
        isInterested: false,
      ),
      BuddyPost(
        id: 'post_6',
        userId: 'user_sneha',
        userName: 'Sneha Kulkarni',
        locationName: 'Jog Falls & Sharavathi Basin',
        stateName: 'Karnataka',
        activityType: 'Kayaking',
        plannedDate: DateTime(2026, 9, 25),
        fitnessLevel: FitnessLevel.intermediate,
        note: 'Monsoon kayaking & camping near Jog falls. Looking for 2 outdoor enthusiasts.',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        interestedCount: 4,
        isInterested: false,
      ),
      BuddyPost(
        id: 'post_7',
        userId: 'user_vikram',
        userName: 'Vikram Singh',
        locationName: 'Zanskar River Expedition',
        stateName: 'Ladakh',
        activityType: 'Rafting',
        plannedDate: DateTime(2026, 10, 12),
        fitnessLevel: FitnessLevel.expert,
        note: 'Chadar & Zanskar white water expedition. High fitness & river experience required.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        interestedCount: 9,
        isInterested: false,
      ),
    ];
  }

  @override
  Future<List<CommunityQuestion>> fetchQuestions() async {
    return [
      CommunityQuestion(
        id: 'q_1',
        userName: 'Meera Nair',
        destinationName: 'Kedarkantha Summit',
        questionText: 'Is crampon required for the summit climb during mid-October, or microspikes sufficient?',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        answers: [
          CommunityAnswer(
            authorName: 'Aarav Sharma',
            answerText: 'Microspikes are usually sufficient in mid-October before heavy snowfall starts in November!',
            createdAt: DateTime.now().subtract(const Duration(hours: 18)),
          ),
          CommunityAnswer(
            authorName: 'Trek Leader Dev',
            answerText: 'Check weather 3 days prior. Carry gaiters just in case of early autumn snow showers.',
            createdAt: DateTime.now().subtract(const Duration(hours: 10)),
          ),
        ],
      ),
      CommunityQuestion(
        id: 'q_2',
        userName: 'Karan Patel',
        destinationName: 'Spiti Valley',
        questionText: 'Which mobile network has the best connectivity between Kaza and Tabo?',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        answers: [
          CommunityAnswer(
            authorName: 'Rohan Gupta',
            answerText: 'BSNL postpaid works best in Kaza town. Airtel has partial 4G near Tabo monastery.',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      CommunityQuestion(
        id: 'q_3',
        userName: 'Divya Sharma',
        destinationName: 'Valley of Flowers',
        questionText: 'Are permits available on-spot at Ghangaria entry gate?',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        answers: [
          CommunityAnswer(
            authorName: 'Ananya Roy',
            answerText: 'Yes, Forest Department permits are issued on arrival at Ghangaria checkpoint for INR 150.',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      ),
    ];
  }
}
