import 'organization.dart';
import 'user.dart';

enum UserRole {
  orgAdmin('org_admin', 'Admin'),
  member('member', 'Member');

  final String value;
  final String label;
  const UserRole(this.value, this.label);

  static UserRole fromString(String? val) {
    if (val == 'org_admin') return UserRole.orgAdmin;
    return UserRole.member;
  }
}

class AuthSession {
  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;
  final DateTime refreshTokenExpiresAt;
  final User user;
  final Organization organization;
  final UserRole role;

  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
    required this.user,
    required this.organization,
    required this.role,
  });

  bool get isExpired => DateTime.now().isAfter(accessTokenExpiresAt);
  bool get isRefreshExpired => DateTime.now().isAfter(refreshTokenExpiresAt);
  bool get isAdmin => role == UserRole.orgAdmin;

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpiresAt,
    DateTime? refreshTokenExpiresAt,
    User? user,
    Organization? organization,
    UserRole? role,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessTokenExpiresAt: accessTokenExpiresAt ?? this.accessTokenExpiresAt,
      refreshTokenExpiresAt: refreshTokenExpiresAt ?? this.refreshTokenExpiresAt,
      user: user ?? this.user,
      organization: organization ?? this.organization,
      role: role ?? this.role,
    );
  }
}
