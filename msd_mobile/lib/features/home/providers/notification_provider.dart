import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/notification_item.dart';
import '../../../core/services/notification_history_service.dart';
import '../../auth/providers/auth_provider.dart';

class NotificationState {
  final List<NotificationItem> notifications;
  final int unreadCount;

  NotificationState({
    required this.notifications,
    required this.unreadCount,
  });
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  StreamSubscription? _subscription;
  Timer? _timer;

  NotificationNotifier() : super(NotificationState(notifications: [], unreadCount: 0)) {
    _init();
  }

  void _init() {
    if (!mounted) return;

    loadNotifications();
    _setupHiveListener();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      loadNotifications();
    });
  }

  void _setupHiveListener() {
    _subscription?.cancel();
    final boxName = notificationHistoryService.currentBoxName;

    if (boxName != null && Hive.isBoxOpen(boxName)) {
      final box = Hive.box<NotificationItem>(boxName);

      loadNotifications();

      _subscription = box.watch().listen((event) {
        debugPrint("🔄 Changement Hive détecté (Box: $boxName, key: ${event.key}, deleted: ${event.deleted})");
        loadNotifications();
      });
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _setupHiveListener();
      });
    }
  }

  void loadNotifications() {
    if (!mounted) return;

    final triggeredNotifications = notificationHistoryService.getTriggeredNotifications();
    final unreadCount = triggeredNotifications.where((n) => !n.isRead).length;

    state = NotificationState(
      notifications: triggeredNotifications,
      unreadCount: unreadCount,
    );

    debugPrint("📊 Notifications chargées: ${triggeredNotifications.length} total, $unreadCount non lues");
  }

  Future<void> cleanupForValidIds(List<String> validIntakeLogIds) async {
    await notificationHistoryService.cleanupNotifications(validIntakeLogIds);
    loadNotifications();
  }

  Future<void> markAllAsRead() async {
    await notificationHistoryService.markAllAsRead();
    loadNotifications();
  }

  Future<void> clearHistory() async {
    debugPrint(" Suppression de toutes les notifications...");
    await notificationHistoryService.clearHistory();

    loadNotifications();
    debugPrint("Toutes les notifications supprimées");
  }

  Future<void> removeNotification(String itemId) async {
    debugPrint(" Suppression notification: $itemId");
    await notificationHistoryService.removeNotification(itemId);
    loadNotifications();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  ref.watch(authProvider);
  return NotificationNotifier();
});