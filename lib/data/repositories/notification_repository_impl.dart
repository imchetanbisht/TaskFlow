import '../../domain/entities/notification_item.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/mock_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final MockDataSource _mockDataSource;

  NotificationRepositoryImpl({required MockDataSource mockDataSource})
      : _mockDataSource = mockDataSource;

  @override
  Future<List<NotificationItem>> getNotifications(String userId) async {
    if (!_mockDataSource.isInitialized) {
      await _mockDataSource.initialize();
    }
    return await _mockDataSource.getNotificationsByUser(userId);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _mockDataSource.markNotificationAsRead(notificationId);
  }
}
