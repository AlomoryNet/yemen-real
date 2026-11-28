import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_item.dart';
import '../repositories/notification_repository.dart';
import 'auth_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationItem>>> {
  final Ref _ref;

  NotificationsNotifier(this._ref) : super(const AsyncValue.loading()) {
    _ref.listen(authProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        loadNotifications();
      }
    });
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final userId = _ref.read(authProvider).user?.id;
    if (userId == null) {
      state = const AsyncValue.data(<NotificationItem>[]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final list = await _ref
          .read(notificationRepositoryProvider)
          .getNotifications(userId);
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    final userId = _ref.read(authProvider).user?.id;
    if (userId == null) return;

    try {
      await _ref
          .read(notificationRepositoryProvider)
          .markAsRead(id: id, userId: userId);
      await loadNotifications();
    } catch (_) {
      // Keep the current list and let the user retry.
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _ref.read(authProvider).user?.id;
    if (userId == null) return;

    try {
      await _ref.read(notificationRepositoryProvider).markAllAsRead(userId);
      await loadNotifications();
    } catch (_) {
      // Keep the current list and let the user retry.
    }
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationItem>>>(
  (ref) => NotificationsNotifier(ref),
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).maybeWhen(
        data: (list) => list.where((item) => !item.isRead).length,
        orElse: () => 0,
      );
});
