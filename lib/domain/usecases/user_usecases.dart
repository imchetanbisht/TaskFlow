import '../entities/notification_item.dart';
import '../entities/user.dart';
import '../repositories/notification_repository.dart';
import '../repositories/user_repository.dart';

class GetOrgMembersUseCase {
  final UserRepository _repository;
  GetOrgMembersUseCase(this._repository);

  Future<List<User>> execute(String orgId) async {
    return await _repository.getOrganizationMembers(orgId);
  }
}

class GetNotificationsUseCase {
  final NotificationRepository _repository;
  GetNotificationsUseCase(this._repository);

  Future<List<NotificationItem>> execute(String userId) async {
    return await _repository.getNotifications(userId);
  }
}

class MarkNotificationReadUseCase {
  final NotificationRepository _repository;
  MarkNotificationReadUseCase(this._repository);

  Future<void> execute(String notifId) async {
    await _repository.markAsRead(notifId);
  }
}
