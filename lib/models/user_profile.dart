import 'community.dart';

class UserProfile {
  final String name;
  final String email;
  final String? avatarUrl;
  final FitnessLevel fitnessLevel; // Trekking & Hiking fitness level
  final List<String> preferredStates;
  final List<String> wellnessPreferences; // Yoga, Ayurveda, Meditation, Silent retreat
  final List<String> culturalInterests; // Festivals, Food & craft, Homestays, Heritage sites
  final String roadTripDuration; // Weekend, 4-7 days, 7+ days
  final bool notifyWeatherAlerts;
  final bool notifyNewDestinations;
  final bool notifyCommunityActivity;
  final String language;
  final bool isDarkMode;

  const UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.fitnessLevel = FitnessLevel.intermediate,
    this.preferredStates = const ['Uttarakhand', 'Himachal Pradesh'],
    this.wellnessPreferences = const ['Yoga', 'Ayurveda'],
    this.culturalInterests = const ['Heritage sites', 'Festivals'],
    this.roadTripDuration = 'Weekend',
    this.notifyWeatherAlerts = true,
    this.notifyNewDestinations = true,
    this.notifyCommunityActivity = true,
    this.language = 'English',
    this.isDarkMode = false,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    FitnessLevel? fitnessLevel,
    List<String>? preferredStates,
    List<String>? wellnessPreferences,
    List<String>? culturalInterests,
    String? roadTripDuration,
    bool? notifyWeatherAlerts,
    bool? notifyNewDestinations,
    bool? notifyCommunityActivity,
    String? language,
    bool? isDarkMode,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      preferredStates: preferredStates ?? this.preferredStates,
      wellnessPreferences: wellnessPreferences ?? this.wellnessPreferences,
      culturalInterests: culturalInterests ?? this.culturalInterests,
      roadTripDuration: roadTripDuration ?? this.roadTripDuration,
      notifyWeatherAlerts: notifyWeatherAlerts ?? this.notifyWeatherAlerts,
      notifyNewDestinations: notifyNewDestinations ?? this.notifyNewDestinations,
      notifyCommunityActivity: notifyCommunityActivity ?? this.notifyCommunityActivity,
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'fitnessLevel': fitnessLevel.name,
      'preferredStates': preferredStates,
      'wellnessPreferences': wellnessPreferences,
      'culturalInterests': culturalInterests,
      'roadTripDuration': roadTripDuration,
      'notifyWeatherAlerts': notifyWeatherAlerts,
      'notifyNewDestinations': notifyNewDestinations,
      'notifyCommunityActivity': notifyCommunityActivity,
      'language': language,
      'isDarkMode': isDarkMode,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? 'Explorer User',
      email: map['email'] as String? ?? 'explorer@travelbuddy.in',
      avatarUrl: map['avatarUrl'] as String?,
      fitnessLevel: FitnessLevel.values.firstWhere(
        (e) => e.name == map['fitnessLevel'],
        orElse: () => FitnessLevel.intermediate,
      ),
      preferredStates: (map['preferredStates'] as List<dynamic>?)?.cast<String>() ??
          const ['Uttarakhand', 'Himachal Pradesh'],
      wellnessPreferences: (map['wellnessPreferences'] as List<dynamic>?)?.cast<String>() ??
          const ['Yoga', 'Ayurveda'],
      culturalInterests: (map['culturalInterests'] as List<dynamic>?)?.cast<String>() ??
          const ['Heritage sites', 'Festivals'],
      roadTripDuration: map['roadTripDuration'] as String? ?? 'Weekend',
      notifyWeatherAlerts: map['notifyWeatherAlerts'] as bool? ?? true,
      notifyNewDestinations: map['notifyNewDestinations'] as bool? ?? true,
      notifyCommunityActivity: map['notifyCommunityActivity'] as bool? ?? true,
      language: map['language'] as String? ?? 'English',
      isDarkMode: map['isDarkMode'] as bool? ?? false,
    );
  }
}
