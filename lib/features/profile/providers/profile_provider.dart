import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/community.dart';
import '../../../models/user_profile.dart';

const String kProfileBoxName = 'profile_box';
const String kProfileDataKey = 'user_profile_data';

class UserProfileNotifier extends Notifier<UserProfile> {
  Box<dynamic>? _box;

  @override
  UserProfile build() {
    _initHive();
    return _loadFromHive();
  }

  void _initHive() {
    if (Hive.isBoxOpen(kProfileBoxName)) {
      _box = Hive.box<dynamic>(kProfileBoxName);
    }
  }

  UserProfile _loadFromHive() {
    if (_box != null && _box!.isOpen) {
      final raw = _box!.get(kProfileDataKey);
      if (raw != null && raw is Map) {
        return UserProfile.fromMap(Map<String, dynamic>.from(raw));
      }
    }
    return const UserProfile(
      name: 'Explorer User',
      email: 'explorer@travelbuddy.in',
      fitnessLevel: FitnessLevel.intermediate,
      preferredStates: ['Uttarakhand', 'Himachal Pradesh'],
    );
  }

  void _saveToHive(UserProfile profile) {
    if (_box != null && _box!.isOpen) {
      _box!.put(kProfileDataKey, profile.toMap());
    }
  }

  void updateName(String newName) {
    state = state.copyWith(name: newName);
    _saveToHive(state);
  }

  void updateFitnessLevel(FitnessLevel level) {
    state = state.copyWith(fitnessLevel: level);
    _saveToHive(state);
  }

  void togglePreferredState(String stateName) {
    final cur = List<String>.from(state.preferredStates);
    if (cur.contains(stateName)) {
      cur.remove(stateName);
    } else {
      cur.add(stateName);
    }
    state = state.copyWith(preferredStates: cur);
    _saveToHive(state);
  }

  void toggleWeatherAlerts(bool enabled) {
    state = state.copyWith(notifyWeatherAlerts: enabled);
    _saveToHive(state);
  }

  void toggleNewDestinations(bool enabled) {
    state = state.copyWith(notifyNewDestinations: enabled);
    _saveToHive(state);
  }

  void toggleCommunityActivity(bool enabled) {
    state = state.copyWith(notifyCommunityActivity: enabled);
    _saveToHive(state);
  }

  void updateLanguage(String newLang) {
    state = state.copyWith(language: newLang);
    _saveToHive(state);
  }

  void toggleDarkMode(bool enabled) {
    state = state.copyWith(isDarkMode: enabled);
    _saveToHive(state);
  }

  void resetProfile() {
    state = const UserProfile(
      name: 'Explorer User',
      email: 'explorer@travelbuddy.in',
    );
    _saveToHive(state);
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(() {
  return UserProfileNotifier();
});
