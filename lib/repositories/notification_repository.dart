import '../config/app_config.dart';
import '../core/exceptions/app_exception.dart';
import '../models/notification_item.dart';
import '../services/supabase_service.dart';

/// Reads and acknowledges in-app notification rows.
class NotificationRepository {
  static const String table = 'notifications';

  Future<List<NotificationItem>> getNotifications(String userId) async {
    if (AppConfig.isDemoMode) {
      _seedDemoNotifications(userId);
      return SupabaseService.demoNotifications
          .where((item) => item.userId == userId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final client = SupabaseService.client;
    if (client == null) return const <NotificationItem>[];

    try {
      final rows = await client
          .from(table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return rows
          .map(
            (row) => NotificationItem.fromJson(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .toList();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  Future<void> markAsRead({
    required String id,
    required String userId,
  }) async {
    if (AppConfig.isDemoMode) {
      final index = SupabaseService.demoNotifications
          .indexWhere((item) => item.id == id && item.userId == userId);
      if (index >= 0) {
        SupabaseService.demoNotifications[index] =
            SupabaseService.demoNotifications[index].copyWith(isRead: true);
      }
      return;
    }

    final client = SupabaseService.client;
    if (client == null) return;

    try {
      await client
          .from(table)
          .update(<String, dynamic>{'is_read': true})
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    if (AppConfig.isDemoMode) {
      SupabaseService.demoNotifications = SupabaseService.demoNotifications
          .map(
            (item) => item.userId == userId ? item.copyWith(isRead: true) : item,
          )
          .toList();
      return;
    }

    final client = SupabaseService.client;
    if (client == null) return;

    try {
      await client
          .from(table)
          .update(<String, dynamic>{'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  void _seedDemoNotifications(String userId) {
    if (SupabaseService.demoNotifications.any(
      (item) => item.userId == userId,
    )) {
      return;
    }
    SupabaseService.demoNotifications.add(
      NotificationItem(
        id: 'demo-notification-$userId',
        userId: userId,
        title: 'عقار جديد يطابق بحثك',
        body: 'ظهر إعلان جديد يطابق أحد عمليات بحثك المحفوظة.',
        link: null,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    );
  }
}
