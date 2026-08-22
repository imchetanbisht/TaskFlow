import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession?> getCurrentSession();

  Future<AuthSession> refreshToken(String refreshToken);

  Future<void> logout();

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });
}
