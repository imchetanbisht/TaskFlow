import '../entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getOrganizationMembers(String orgId);
  Future<User?> getUserById(String userId);
}
