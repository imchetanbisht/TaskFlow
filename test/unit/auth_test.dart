import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/errors/app_exception.dart';
import 'package:taskflow/core/storage/local_storage_service.dart';
import 'package:taskflow/core/storage/secure_storage_service.dart';
import 'package:taskflow/data/datasources/local_cache_data_source.dart';
import 'package:taskflow/data/datasources/mock_data_source.dart';
import 'package:taskflow/data/repositories/auth_repository_impl.dart';
import 'package:taskflow/domain/entities/auth_session.dart';
import 'package:taskflow/domain/usecases/auth_usecases.dart';

import '../test_mock_data.dart';

void main() {
  late MockDataSource mockDataSource;
  late ISecureStorageService secureStorage;
  late ILocalStorageService localStorage;
  late LocalCacheDataSource cacheDataSource;
  late AuthRepositoryImpl authRepository;
  late LoginUseCase loginUseCase;
  late GetCurrentSessionUseCase getSessionUseCase;
  late RefreshTokenUseCase refreshTokenUseCase;
  late LogoutUseCase logoutUseCase;

  setUp(() async {
    mockDataSource = MockDataSource();
    await mockDataSource.initialize(rawJson: testMockDataJson);
    secureStorage = InMemorySecureStorageService();
    localStorage = InMemoryLocalStorageService();
    cacheDataSource = LocalCacheDataSource(
      localStorage: localStorage,
      secureStorage: secureStorage,
    );
    authRepository = AuthRepositoryImpl(
      mockDataSource: mockDataSource,
      cacheDataSource: cacheDataSource,
    );
    loginUseCase = LoginUseCase(authRepository);
    getSessionUseCase = GetCurrentSessionUseCase(authRepository);
    refreshTokenUseCase = RefreshTokenUseCase(authRepository);
    logoutUseCase = LogoutUseCase(authRepository);
  });

  group('Auth Unit Tests', () {
    test('Successful login with Org Admin credentials', () async {
      final session = await loginUseCase.execute(
        email: 'ava.admin@nimbusdigital.test',
        password: 'Password123!',
      );

      expect(session.user.name, 'Ava Thompson');
      expect(session.organization.id, 'org_a1b2c3');
      expect(session.role, UserRole.orgAdmin);
      expect(session.isAdmin, true);
      expect(session.accessToken, isNotEmpty);
      expect(session.isExpired, false);
    });

    test('Successful login with Member credentials', () async {
      final session = await loginUseCase.execute(
        email: 'marcus.member@nimbusdigital.test',
        password: 'Password123!',
      );

      expect(session.user.name, 'Marcus Lee');
      expect(session.organization.id, 'org_a1b2c3');
      expect(session.role, UserRole.member);
      expect(session.isAdmin, false);
    });

    test('Login fails with invalid password', () async {
      expect(
        () => loginUseCase.execute(
          email: 'ava.admin@nimbusdigital.test',
          password: 'WrongPassword!',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('Login validates empty or malformed email', () async {
      expect(
        () => loginUseCase.execute(
          email: 'not-an-email',
          password: 'Password123!',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Session restore from storage returns saved session', () async {
      await loginUseCase.execute(
        email: 'ava.admin@nimbusdigital.test',
        password: 'Password123!',
      );

      final restoredSession = await getSessionUseCase.execute();
      expect(restoredSession, isNotNull);
      expect(restoredSession!.user.name, 'Ava Thompson');
    });

    test('Token refresh updates accessToken and expiry', () async {
      final session = await loginUseCase.execute(
        email: 'ava.admin@nimbusdigital.test',
        password: 'Password123!',
      );

      final refreshed = await refreshTokenUseCase.execute(session.refreshToken);
      expect(refreshed.accessToken, startsWith('refreshed.access.token'));
      expect(refreshed.user.id, session.user.id);
    });

    test('Logout clears stored session', () async {
      await loginUseCase.execute(
        email: 'ava.admin@nimbusdigital.test',
        password: 'Password123!',
      );

      await logoutUseCase.execute();
      final sessionAfterLogout = await getSessionUseCase.execute();
      expect(sessionAfterLogout, isNull);
    });
  });
}
