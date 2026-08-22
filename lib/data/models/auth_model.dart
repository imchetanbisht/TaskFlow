import '../../domain/entities/auth_session.dart';
import 'organization_model.dart';
import 'user_model.dart';

class TestCredentialModel {
  final String email;
  final String password;
  final String orgId;
  final String role;

  const TestCredentialModel({
    required this.email,
    required this.password,
    required this.orgId,
    required this.role,
  });

  factory TestCredentialModel.fromJson(Map<String, dynamic> json) {
    return TestCredentialModel(
      email: json['email'] as String,
      password: json['password'] as String,
      orgId: json['org_id'] as String,
      role: json['role'] as String,
    );
  }
}

class MockLoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final int accessTokenExpiresInSeconds;
  final int refreshTokenExpiresInSeconds;

  const MockLoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresInSeconds,
    required this.refreshTokenExpiresInSeconds,
  });

  factory MockLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return MockLoginResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      accessTokenExpiresInSeconds: json['access_token_expires_in_seconds'] as int? ?? 900,
      refreshTokenExpiresInSeconds: json['refresh_token_expires_in_seconds'] as int? ?? 604800,
    );
  }
}

class StoredSessionModel {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;
  final UserModel user;
  final OrganizationModel organization;
  final String role;

  const StoredSessionModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
    required this.user,
    required this.organization,
    required this.role,
  });

  factory StoredSessionModel.fromSession(AuthSession session) {
    return StoredSessionModel(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      accessTokenExpiresAt: session.accessTokenExpiresAt,
      refreshTokenExpiresAt: session.refreshTokenExpiresAt,
      user: UserModel.fromEntity(session.user),
      organization: OrganizationModel.fromEntity(session.organization),
      role: session.role.value,
    );
  }

  AuthSession toSession() {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt,
      refreshTokenExpiresAt: refreshTokenExpiresAt,
      user: user,
      organization: organization,
      role: UserRole.fromString(role),
    );
  }

  factory StoredSessionModel.fromJson(Map<String, dynamic> json) {
    return StoredSessionModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      accessTokenExpiresAt: DateTime.parse(json['access_token_expires_at'] as String),
      refreshTokenExpiresAt: DateTime.parse(json['refresh_token_expires_at'] as String),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      organization: OrganizationModel.fromJson(json['organization'] as Map<String, dynamic>),
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'access_token_expires_at': accessTokenExpiresAt.toIso8601String(),
      'refresh_token_expires_at': refreshTokenExpiresAt.toIso8601String(),
      'user': user.toJson(),
      'organization': organization.toJson(),
      'role': role,
    };
  }
}
