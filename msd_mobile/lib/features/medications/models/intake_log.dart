import 'package:flutter/material.dart';
import 'intake_status.dart';

class IntakeLog {
  final String id;
  final String treatmentId;
  final DateTime intakeDate;
  final TimeOfDay slotTime;
  final int daySlotIndex;
  final DateTime? actualTakenDateTime;
  final IntakeStatus status;

  IntakeLog({
    required this.id,
    required this.treatmentId,
    required this.intakeDate,
    required this.slotTime,
    required this.daySlotIndex,
    this.actualTakenDateTime,
    this.status = IntakeStatus.pending,
  });

  bool get isMissed {
      return status == IntakeStatus.missed;
  }

  factory IntakeLog.fromJson(Map<String, dynamic> json) {
    final timeStr = json['slotTime'] as String;
    final timeParts = timeStr.split(':');
    
    return IntakeLog(
      id: json['id'] ?? '',
      treatmentId: json['treatmentId'] ?? '',
      intakeDate: DateTime.parse(json['intakeDate']),
      slotTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      daySlotIndex: json['daySlotIndex'] ?? 0,
      actualTakenDateTime: json['actualTakenDateTime'] != null
          ? DateTime.parse(json['actualTakenDateTime'])
          : null,
      status: _parseStatus(json['status']),
    );
  }

  static IntakeStatus _parseStatus(String? status) {
    if (status == null) return IntakeStatus.pending;
    return IntakeStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == status.toUpperCase(),
      orElse: () => IntakeStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'treatmentId': treatmentId,
      'intakeDate': "${intakeDate.year}-${intakeDate.month.toString().padLeft(2, '0')}-${intakeDate.day.toString().padLeft(2, '0')}",
      'slotTime': "${slotTime.hour.toString().padLeft(2, '0')}:${slotTime.minute.toString().padLeft(2, '0')}:00",
      'daySlotIndex': daySlotIndex,
      'actualTakenDateTime': actualTakenDateTime?.toIso8601String(),
      'status': status.name.toUpperCase(),
    };
  }

  IntakeLog copyWith({
    IntakeStatus? status,
    DateTime? actualTakenDateTime,
    TimeOfDay? slotTime,
  }) {
    return IntakeLog(
      id: id,
      treatmentId: treatmentId,
      intakeDate: intakeDate,
      slotTime: slotTime ?? this.slotTime,
      daySlotIndex: daySlotIndex,
      actualTakenDateTime: actualTakenDateTime ?? this.actualTakenDateTime,
      status: status ?? this.status,
    );
  }
}
