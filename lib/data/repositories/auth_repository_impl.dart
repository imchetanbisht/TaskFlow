import 'dart:math';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_cache_data_source.dart';
import '../datasources/mock_data_source.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockDataSource _mockDataSource;
  final LocalCacheDataSource _cacheDataSource;

  AuthRepositoryImpl({
    required MockDataSource mockDataSource,
    required LocalCacheDataSource cacheDataSource,
  })  : _mockDataSource = mockDataSource,
        _cacheDataSource = cacheDataSource;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }

    final cred = await _mockDataSource.findCredential(email, password);
    if (cred == null) {
      throw const AuthException(
        'Invalid email or password. Please check your credentials.',
        code: 'INVALID_CREDENTIALS',
      );
    }

    // Find the user model by email
    final users = await _mockDataSource.getUsers();
    UserModel? user;
    try {
      user = users.firstWhere((u) => u.email.toLowerCase() == cred.email.toLowerCase());
    } catch (_) {
      user = UserModel(
        id: 'user_${Random().nextInt(999)}',
        name: cred.email.split('@').first.replaceAll('.', ' ').toUpperCase(),
        email: cred.email,
        avatarUrl: 'https://i.pravatar.cc/150?img=${Random().nextInt(70) + 1}',
      );
    }

    // Find the organization
    final org = await _mockDataSource.getOrganizationById(cred.orgId);
    if (org == null) {
      throw const NotFoundException('Organization not found for user.');
    }

    final mockResponse = _mockDataSource.getMockLoginResponse();
    final now = DateTime.now();
    final accessExpiresIn = mockResponse?.accessTokenExpiresInSeconds ?? AppConstants.defaultTokenExpirySeconds;
    final refreshExpiresIn = mockResponse?.refreshTokenExpiresInSeconds ?? AppConstants.defaultRefreshTokenExpirySeconds;

    final session = AuthSession(
      accessToken: mockResponse?.accessToken ?? 'mock.access.token.${now.millisecondsSinceEpoch}',
      refreshToken: mockResponse?.refreshToken ?? 'mock.refresh.token.${now.millisecondsSinceEpoch}',
      accessTokenExpiresAt: now.add(Duration(seconds: accessExpiresIn)),
      refreshTokenExpiresAt: now.add(Duration(seconds: refreshExpiresIn)),
      user: user,
      organization: org,
      role: UserRole.fromString(cred.role),
    );

    // Save session to secure storage
    await _cacheDataSource.saveSession(StoredSessionModel.fromSession(session));
    return session;
  }

  @override
  Future<AuthSession?> getCurrentSession() async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }

    final stored = await _cacheDataSource.getSession();
    if (stored == null) return null;

    final session = stored.toSession();

    // Check if refresh token has expired
    if (session.isRefreshExpired) {
      await logout();
      return null;
    }

    // If access token is expired, auto-refresh
    if (session.isExpired) {
      try {
        return await refreshToken(session.refreshToken);
      } catch (_) {
        await logout();
        return null;
      }
    }

    return session;
  }

  @override
  Future<AuthSession> refreshToken(String refreshToken) async {
    final stored = await _cacheDataSource.getSession();
    if (stored == null) {
      throw const AuthException('No active session found.');
    }

    final now = DateTime.now();
    final newExpiresAt = now.add(const Duration(seconds: AppConstants.defaultTokenExpirySeconds));
    final newSession = stored.toSession().copyWith(
      accessToken: 'refreshed.access.token.${now.millisecondsSinceEpoch}',
      accessTokenExpiresAt: newExpiresAt,
    );

    await _cacheDataSource.saveSession(StoredSessionModel.fromSession(newSession));
    return newSession;
  }

  @override
  Future<void> logout() async {
    await _cacheDataSource.clearSession();
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }

    // Use default organization Org A
    final orgs = await _mockDataSource.getOrganizations();
    final defaultOrg = orgs.isNotEmpty
        ? orgs.first
        : const Organization(id: 'org_a1b2c3', name: 'Nimbus Digital');

    final newUser = UserModel(
      id: 'user_reg_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
    );

    final now = DateTime.now();
    final session = AuthSession(
      accessToken: 'mock.access.token.reg.${now.millisecondsSinceEpoch}',
      refreshToken: 'mock.refresh.token.reg.${now.millisecondsSinceEpoch}',
      accessTokenExpiresAt: now.add(const Duration(seconds: AppConstants.defaultTokenExpirySeconds)),
      refreshTokenExpiresAt: now.add(const Duration(seconds: AppConstants.defaultRefreshTokenExpirySeconds)),
      user: newUser,
      organization: defaultOrg,
      role: UserRole.member,
    );

    await _cacheDataSource.saveSession(StoredSessionModel.fromSession(session));
    return session;
  }
}
