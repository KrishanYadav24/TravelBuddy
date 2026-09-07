import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State representation for authentication.
class AuthState {
  final bool isAuthenticated;
  final bool isGuest;
  final String? email;
  final String? authMethod;

  const AuthState({
    this.isAuthenticated = false,
    this.isGuest = false,
    this.email,
    this.authMethod,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isGuest,
    String? email,
    String? authMethod,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isGuest: isGuest ?? this.isGuest,
      email: email ?? this.email,
      authMethod: authMethod ?? this.authMethod,
    );
  }
}

/// Riverpod Auth Notifier managing authentication state across the application.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  void loginWithGoogle() {
    state = state.copyWith(
      isAuthenticated: true,
      isGuest: false,
      authMethod: 'google',
    );
  }

  void loginWithApple() {
    state = state.copyWith(
      isAuthenticated: true,
      isGuest: false,
      authMethod: 'apple',
    );
  }

  void loginWithEmail(String email) {
    state = state.copyWith(
      isAuthenticated: true,
      isGuest: false,
      email: email,
      authMethod: 'email',
    );
  }

  void continueAsGuest() {
    state = state.copyWith(
      isAuthenticated: false,
      isGuest: true,
      authMethod: 'guest',
    );
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
