import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_session.dart';
import 'app_providers.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final AuthSession session;
  const Authenticated(this.session);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  Timer? _expiryTimer;

  AuthNotifier(this._ref) : super(const AuthInitial());

  AuthSession? get currentSession {
    final s = state;
    return s is Authenticated ? s.session : null;
  }

  Future<void> checkSession() async {
    state = const AuthLoading();
    try {
      final session = await _ref.read(getCurrentSessionUseCaseProvider).execute();
      if (session != null) {
        state = Authenticated(session);
        _scheduleTokenExpiryCheck(session);
      } else {
        state = const Unauthenticated();
      }
    } catch (e) {
      state = const Unauthenticated();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final session = await _ref.read(loginUseCaseProvider).execute(
            email: email,
            password: password,
          );
      state = Authenticated(session);
      _scheduleTokenExpiryCheck(session);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AuthLoading();
    try {
      final session = await _ref.read(registerUseCaseProvider).execute(
            name: name,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
          );
      state = Authenticated(session);
      _scheduleTokenExpiryCheck(session);
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<void> manualRefreshToken() async {
    final session = currentSession;
    if (session == null) return;

    try {
      final newSession = await _ref
          .read(refreshTokenUseCaseProvider)
          .execute(session.refreshToken);
      state = Authenticated(newSession);
      _scheduleTokenExpiryCheck(newSession);
    } catch (e) {
      await logout();
    }
  }

  Future<void> logout() async {
    _expiryTimer?.cancel();
    state = const AuthLoading();
    await _ref.read(logoutUseCaseProvider).execute();
    state = const Unauthenticated();
  }

  void _scheduleTokenExpiryCheck(AuthSession session) {
    _expiryTimer?.cancel();
    final remaining = session.accessTokenExpiresAt.difference(DateTime.now());
    if (remaining.isNegative) {
      manualRefreshToken();
    } else {
      _expiryTimer = Timer(remaining, () {
        manualRefreshToken();
      });
    }
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
