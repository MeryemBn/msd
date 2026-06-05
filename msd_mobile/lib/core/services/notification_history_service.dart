import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/home/models/notification_item.dart';

class NotificationHistoryService {
  static String? _currentUserBoxName;

  String? get currentBoxName => _currentUserBoxName;

  Future<void> initForUser(String userId) async {
    _currentUserBoxName = 'notifications_box_$userId';

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NotificationItemAdapter());
    }

    if (!Hive.isBoxOpen(_currentUserBoxName!)) {
      await Hive.openBox<NotificationItem>(_currentUserBoxName!);
    }
    
    // Nettoyer les doublons hérités des anciennes versions (clés numériques vs IDs)
    await _migrateAndCleanup();
    
    debugPrint("📦 Notification box initialized and cleaned for user: $userId");
  }

  Box<NotificationItem>? get _box {
    if (_currentUserBoxName == null || !Hive.isBoxOpen(_currentUserBoxName!)) return null;
    return Hive.box<NotificationItem>(_currentUserBoxName!);
  }

  bool containsNotification(String id) {
    final box = _box;
    if (box == null) return false;
    return box.containsKey(id);
  }

  Future<void> addTriggeredNotification(NotificationItem item) async {
    final box = _box;
    if (box == null) return;

    // Utilisation de l'ID comme clé UNIQUE (écrase l'existant si nécessaire)
    if (box.containsKey(item.id)) {
      final existing = box.get(item.id);
      if (existing != null && existing.isRead) return;
    }

    await box.put(item.id, item);
    debugPrint("✅ Notification persistée : ${item.id}");
  }

  Future<void> _migrateAndCleanup() async {
    final box = _box;
    if (box == null) return;
    
    final Map<String, NotificationItem> uniqueMap = {};
    final List<dynamic> oldKeysToDelete = [];

    for (var key in box.keys) {
      final item = box.get(key);
      if (item != null) {
        if (key != item.id) {
          oldKeysToDelete.add(key);
        }
        if (!uniqueMap.containsKey(item.id) || item.isRead) {
          uniqueMap[item.id] = item;
        }
      }
    }

    if (oldKeysToDelete.isNotEmpty) {
      await box.deleteAll(oldKeysToDelete);
      for (var entry in uniqueMap.entries) {
        if (!box.containsKey(entry.key)) {
          await box.put(entry.key, entry.value);
        }
      }
      debugPrint("🧹 ${oldKeysToDelete.length} résidus de notifications supprimés.");
    }
  }

  /// Nettoie les notifications obsolètes (utilisé par le module médicaments)
  Future<void> cleanupNotifications(List<String> validIds) async {
    final box = _box;
    if (box == null) return;
    
    final keysToDelete = <dynamic>[];
    for (final key in box.keys) {
      final item = box.get(key);
      if (item != null &&
          item.type == 'medication' &&
          !validIds.contains(item.id) &&
          item.id != "999") {
        keysToDelete.add(key);
      }
    }

    if (keysToDelete.isNotEmpty) {
      await box.deleteAll(keysToDelete);
      debugPrint("🧹 ${keysToDelete.length} notifications obsolètes supprimées");
    }
  }

  Future<void> removeNotification(String itemId) async {
    final box = _box;
    if (box == null) return;
    await box.delete(itemId);
  }

  List<NotificationItem> getAllNotifications() {
    final box = _box;
    if (box == null) return [];
    
    final Map<String, NotificationItem> finalUniqueMap = {};
    for (var item in box.values) {
      finalUniqueMap[item.id] = item;
    }
    
    final items = finalUniqueMap.values.toList();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  List<NotificationItem> getTriggeredNotifications() {
    final now = DateTime.now();
    return getAllNotifications().where((item) {
      if (item.type == 'sos' || item.type == 'appointment' || item.type == 'sos_status' || item.type == 'review') return true;
      return !item.timestamp.isAfter(now);
    }).toList();
  }

  int getUnreadCount() => getTriggeredNotifications().where((item) => !item.isRead).length;

  Future<void> markAllAsRead() async {
    final box = _box;
    if (box == null) return;
    for (var item in box.values) {
      if (!item.isRead) {
        item.isRead = true;
        await item.save();
      }
    }
  }

  Future<void> clearHistory() async => await _box?.clear();

  Future<void> closeBox() async {
    if (_currentUserBoxName != null && Hive.isBoxOpen(_currentUserBoxName!)) {
      await Hive.box<NotificationItem>(_currentUserBoxName!).close();
    }
    _currentUserBoxName = null;
  }
}

final notificationHistoryService = NotificationHistoryService();
