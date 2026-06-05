import 'package:flutter/material.dart';

enum ReminderType { alarm, notification, none }

class Medication {
  final String id;
  final String userId;
  final String medicationName;
  final String dosage;
  final String instructions;
  final DateTime startDate;
  final int durationInDays;
  final List<TimeOfDay> intakeTimes;
  final int initialStock;
  final int currentStock;
  final int lowStockThreshold;
  final bool isStockLow;

  final ReminderType reminderType;
  final int leadTimeMinutes;
  final int snoozeIntervalMinutes;

  Medication({
    required this.id,
    required this.userId,
    required this.medicationName,
    required this.dosage,
    required this.instructions,
    required this.startDate,
    required this.durationInDays,
    required this.intakeTimes,
    required this.initialStock,
    required this.currentStock,
    required this.lowStockThreshold,
    this.isStockLow = false,
    this.reminderType = ReminderType.notification,
    this.leadTimeMinutes = 5,
    this.snoozeIntervalMinutes = 10,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    dynamic val(String k1, String k2) => json[k1] ?? json[k2];

    List<TimeOfDay> parseTimes(dynamic t) {
      if (t == null || t is! List) return [];
      return t.map((e) {
        final parts = e.toString().split(':');
        return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0
        );
      }).toList();
    }

    return Medication(
      id: json['id']?.toString() ?? '',
      userId: val('user_id', 'userId')?.toString() ?? '',
      medicationName: val('medication_name', 'medicationName')?.toString() ?? 'Inconnu',
      dosage: json['dosage']?.toString() ?? '',
      instructions: json['instructions']?.toString() ?? '',
      startDate: DateTime.tryParse(val('start_date', 'startDate')?.toString() ?? '') ?? DateTime.now(),
      durationInDays: int.tryParse(val('duration_in_days', 'durationInDays')?.toString() ?? '0') ?? 0,
      intakeTimes: parseTimes(val('intake_times', 'intakeTimes')),
      initialStock: int.tryParse(val('initial_stock', 'initialStock')?.toString() ?? '0') ?? 0,
      currentStock: int.tryParse(val('current_stock', 'currentStock')?.toString() ?? '0') ?? 0,
      lowStockThreshold: int.tryParse(val('low_stock_threshold', 'lowStockThreshold')?.toString() ?? '0') ?? 0,
      isStockLow: val('is_stock_low', 'isStockLow') == true,
      reminderType: ReminderType.values.firstWhere(
        (e) => e.name.toUpperCase() == (val('reminder_type', 'reminderType') ?? 'NOTIFICATION').toString().toUpperCase(),
        orElse: () => ReminderType.notification,
      ),
      leadTimeMinutes: int.tryParse(val('lead_time_minutes', 'leadTimeMinutes')?.toString() ?? '0') ?? 0,
      snoozeIntervalMinutes: int.tryParse(val('snooze_interval_minutes', 'snoozeIntervalMinutes')?.toString() ?? '10') ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
    'medicationName': medicationName,
    'dosage': dosage,
    'instructions': instructions,
    'startDate': "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
    'durationInDays': durationInDays,
    'intakeTimes': intakeTimes.map((t) => "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}").toList(),
    'initialStock': initialStock,
    'lowStockThreshold': lowStockThreshold,
    'reminderType': reminderType.name.toUpperCase(),
    'leadTimeMinutes': leadTimeMinutes,
    'snoozeIntervalMinutes': snoozeIntervalMinutes,
  };

  Medication copyWith({String? id, String? userId, String? medicationName, String? dosage, String? instructions, DateTime? startDate, int? durationInDays, List<TimeOfDay>? intakeTimes, int? initialStock, int? currentStock, int? lowStockThreshold, bool? isStockLow, ReminderType? reminderType, int? leadTimeMinutes, int? snoozeIntervalMinutes}) {
    return Medication(
      id: id ?? this.id, userId: userId ?? this.userId, medicationName: medicationName ?? this.medicationName, dosage: dosage ?? this.dosage, instructions: instructions ?? this.instructions, startDate: startDate ?? this.startDate, durationInDays: durationInDays ?? this.durationInDays, intakeTimes: intakeTimes ?? this.intakeTimes, initialStock: initialStock ?? this.initialStock, currentStock: currentStock ?? this.currentStock, lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold, isStockLow: isStockLow ?? this.isStockLow, reminderType: reminderType ?? this.reminderType, leadTimeMinutes: leadTimeMinutes ?? this.leadTimeMinutes, snoozeIntervalMinutes: snoozeIntervalMinutes ?? this.snoozeIntervalMinutes,
    );
  }
}
