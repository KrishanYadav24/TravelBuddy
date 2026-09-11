enum FitnessLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

extension FitnessLevelExtension on FitnessLevel {
  String get displayName {
    switch (this) {
      case FitnessLevel.beginner:
        return 'Beginner';
      case FitnessLevel.intermediate:
        return 'Intermediate';
      case FitnessLevel.advanced:
        return 'Advanced';
      case FitnessLevel.expert:
        return 'Expert';
    }
  }
}

class BuddyPost {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final String locationName;
  final String? stateName;
  final String? activityType;
  final DateTime plannedDate;
  final FitnessLevel fitnessLevel;
  final String note;
  final DateTime createdAt;
  final int interestedCount;
  final bool isInterested;

  const BuddyPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.locationName,
    this.stateName,
    this.activityType,
    required this.plannedDate,
    required this.fitnessLevel,
    required this.note,
    required this.createdAt,
    this.interestedCount = 0,
    this.isInterested = false,
  });

  BuddyPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    String? locationName,
    String? stateName,
    String? activityType,
    DateTime? plannedDate,
    FitnessLevel? fitnessLevel,
    String? note,
    DateTime? createdAt,
    int? interestedCount,
    bool? isInterested,
  }) {
    return BuddyPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      locationName: locationName ?? this.locationName,
      stateName: stateName ?? this.stateName,
      activityType: activityType ?? this.activityType,
      plannedDate: plannedDate ?? this.plannedDate,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      interestedCount: interestedCount ?? this.interestedCount,
      isInterested: isInterested ?? this.isInterested,
    );
  }
}

class CommunityAnswer {
  final String authorName;
  final String answerText;
  final DateTime createdAt;

  const CommunityAnswer({
    required this.authorName,
    required this.answerText,
    required this.createdAt,
  });
}

class CommunityQuestion {
  final String id;
  final String userName;
  final String destinationName;
  final String questionText;
  final List<CommunityAnswer> answers;
  final DateTime createdAt;

  const CommunityQuestion({
    required this.id,
    required this.userName,
    required this.destinationName,
    required this.questionText,
    this.answers = const [],
    required this.createdAt,
  });

  CommunityQuestion copyWith({
    String? id,
    String? userName,
    String? destinationName,
    String? questionText,
    List<CommunityAnswer>? answers,
    DateTime? createdAt,
  }) {
    return CommunityQuestion(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      destinationName: destinationName ?? this.destinationName,
      questionText: questionText ?? this.questionText,
      answers: answers ?? this.answers,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
