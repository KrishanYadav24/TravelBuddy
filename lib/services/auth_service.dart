import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/env_config.dart';

class AuthUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isAnonymous;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
  });
}

class AuthService {
  AuthUser? _currentUser = const AuthUser(
    uid: 'demo_user_101',
    email: 'traveler@travelbuddy.in',
    displayName: 'Himalayan Explorer',
    photoUrl: 'https://picsum.photos/seed/user_avatar/200',
  );

  /// Get active authenticated user stream or current instance
  AuthUser? get currentUser => _currentUser;

  Future<AuthUser?> signInWithEmail(String email, String password) async {
    if (!EnvConfig.useMockData) {
      // Firebase Auth integration point
      // await FirebaseAuth.instance.signInWithEmailAndPassword(...)
    }
    _currentUser = AuthUser(
      uid: 'user_${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
    );
    return _currentUser;
  }

  Future<AuthUser?> signInAnonymously() async {
    _currentUser = const AuthUser(
      uid: 'anon_guest',
      email: 'guest@travelbuddy.in',
      displayName: 'Guest Traveler',
      isAnonymous: true,
    );
    return _currentUser;
  }

  Future<void> signOut() async {
    _currentUser = null;
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthUserNotifier extends Notifier<AuthUser?> {
  @override
  AuthUser? build() {
    return ref.watch(authServiceProvider).currentUser;
  }

  void setUser(AuthUser? user) {
    state = user;
  }
}

final authUserProvider = NotifierProvider<AuthUserNotifier, AuthUser?>(() {
  return AuthUserNotifier();
});
