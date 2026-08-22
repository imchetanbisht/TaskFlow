import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/entities/user.dart';
import 'app_providers.dart';
import 'auth_notifier.dart';

final orgMembersProvider = FutureProvider<List<User>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  if (authState is! Authenticated) return [];
  return await ref
      .watch(getOrgMembersUseCaseProvider)
      .execute(authState.session.organization.id);
});

class NotificationNotifier extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  final Ref _ref;

  NotificationNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final authState = _ref.read(authNotifierProvider);
    if (authState is! Authenticated) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final items = await _ref
          .read(getNotificationsUseCaseProvider)
          .execute(authState.session.user.id);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String notifId) async {
    await _ref.read(markNotificationReadUseCaseProvider).execute(notifId);
    state = state.whenData((items) {
      return items.map((item) {
        if (item.id == notifId) {
          return item.copyWith(read: true);
        }
        return item;
      }).toList();
    });
  }
}

final notificationsNotifierProvider = StateNotifierProvider<NotificationNotifier,
    AsyncValue<List<NotificationItem>>>((ref) {
  return NotificationNotifier(ref);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifsAsync = ref.watch(notificationsNotifierProvider);
  return notifsAsync.when(
    data: (list) => list.where((n) => !n.read).length,
    loading: () => 0,
    error: (e, st) => 0,
  );
});
