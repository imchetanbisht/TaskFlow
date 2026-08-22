import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/mock_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final MockDataSource _mockDataSource;

  UserRepositoryImpl({required MockDataSource mockDataSource})
      : _mockDataSource = mockDataSource;

  @override
  Future<List<User>> getOrganizationMembers(String orgId) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }

    final orgMembers = await _mockDataSource.getOrgMembers(orgId);
    final memberUserIds = orgMembers.map((m) => m.userId).toSet();

    final allUsers = await _mockDataSource.getUsers();
    return allUsers.where((u) => memberUserIds.contains(u.id)).toList();
  }

  @override
  Future<User?> getUserById(String userId) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }
    return await _mockDataSource.getUserById(userId);
  }
}
