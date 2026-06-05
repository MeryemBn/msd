import 'package:hive/hive.dart';

part 'notification_item.g.dart';

@HiveType(typeId: 0)
class NotificationItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  bool isRead;

  @HiveField(5)
  final String type; // 'medication', 'stock', 'sos', 'appointment', 'review'

  @HiveField(6)
  final String? medicationName; // Nouveau champ pour le nom du médicament

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type = 'medication',
    this.medicationName,
  });
}
