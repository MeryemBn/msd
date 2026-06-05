import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/medication.dart';
import '../models/intake_log.dart';
import '../models/intake_status.dart';
import '../services/medication_service.dart';
import '../../../core/services/notification_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import 'package:uuid/uuid.dart';

class MedicationState {
  final List<Medication> medications;
  final List<IntakeLog> intakeLogs;
  final bool isLoading;
  final String? error;

  MedicationState({
    required this.medications,
    required this.intakeLogs,
    this.isLoading = false,
    this.error,
  });

  MedicationState copyWith({
    List<Medication>? medications,
    List<IntakeLog>? intakeLogs,
    bool? isLoading,
    String? error,
  }) {
    return MedicationState(
      medications: medications ?? this.medications,
      intakeLogs: intakeLogs ?? this.intakeLogs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MedicationNotifier extends StateNotifier<MedicationState> {
  MedicationNotifier({bool isEmpty = false}) : super(MedicationState(medications: [], intakeLogs: [])) {
    if (!isEmpty) {
      loadData();
    }
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final medications = await medicationService.getMyMedications();
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 15));
      final end = now.add(const Duration(days: 15));
      final allLogs = await medicationService.getDailyIntakes(start, endDate: end);

      state = state.copyWith(
        medications: medications,
        intakeLogs: allLogs,
        isLoading: false,
      );

      _scheduleFutureAlarms(hoursAhead: 24);
      _updateEndOfDayBilan();
      notificationService.scheduleDailyStockCheck(medications);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadLogsForRange(DateTime start, DateTime end) async {
    final hasStart = state.intakeLogs.any((l) => isSameDay(l.intakeDate, start));
    final hasEnd = state.intakeLogs.any((l) => isSameDay(l.intakeDate, end));
    if (hasStart && hasEnd) return;

    state = state.copyWith(isLoading: true);
    try {
      final newLogs = await medicationService.getDailyIntakes(start, endDate: end);
      final existingIds = state.intakeLogs.map((l) => l.id).toSet();
      final uniqueNewLogs = newLogs.where((l) => !existingIds.contains(l.id)).toList();

      state = state.copyWith(
        intakeLogs: [...state.intakeLogs, ...uniqueNewLogs],
        isLoading: false,
      );
      _scheduleFutureAlarms(hoursAhead: 24);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _scheduleFutureAlarms({int hoursAhead = 24}) {
    final now = DateTime.now();
    final limit = now.add(Duration(hours: hoursAhead));

    for (var log in state.intakeLogs) {
      if (log.status == IntakeStatus.pending) {
        final med = state.medications.firstWhere((m) => m.id == log.treatmentId,
            orElse: () => Medication(id: '', userId: '', medicationName: '', dosage: '', instructions: '', startDate: now, durationInDays: 0, intakeTimes: [], initialStock: 0, currentStock: 0, lowStockThreshold: 0, reminderType: ReminderType.notification, leadTimeMinutes: 0, snoozeIntervalMinutes: 0)
        );

        if (med.id.isNotEmpty) {
          final scheduledTime = DateTime(
            log.intakeDate.year, log.intakeDate.month, log.intakeDate.day,
            log.slotTime.hour, log.slotTime.minute,
          ).subtract(Duration(minutes: med.leadTimeMinutes));

          if (scheduledTime.isAfter(now.add(const Duration(seconds: 10))) && scheduledTime.isBefore(limit)) {
            _scheduleSingleAlarm(med, log.intakeDate, log.slotTime, log.id);
          }
        }
      }
    }
  }

  Future<void> refillStock(String medId, int addedQuantity) async {
    try {
      final medIndex = state.medications.indexWhere((m) => m.id == medId);
      if (medIndex == -1) return;

      final med = state.medications[medIndex];
      final newStock = med.currentStock + addedQuantity;
      final updatedMed = await medicationService.updateMedicationStock(medId, newStock);

      final updatedMeds = List<Medication>.from(state.medications);
      updatedMeds[medIndex] = updatedMed;
      state = state.copyWith(medications: updatedMeds);

      if (!updatedMed.isStockLow) {
        await notificationService.cancelStockReminders(medId.hashCode);
      }
      notificationService.scheduleDailyStockCheck(updatedMeds);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addMedication({
    required String name,
    required String dosage,
    required String instruction,
    required List<TimeOfDay> times,
    required int initialStock,
    required int lowStockThreshold,
    required int duration,
    required DateTime startDate,
    required ReminderType reminderType,
    required int leadTimeMinutes,
    required int snoozeInterval,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final uuid = const Uuid();
      final newMed = Medication(
        id: uuid.v4(),
        userId: '',
        medicationName: name,
        dosage: dosage,
        instructions: instruction,
        startDate: startDate,
        durationInDays: duration,
        intakeTimes: times,
        initialStock: initialStock,
        currentStock: initialStock,
        lowStockThreshold: lowStockThreshold,
        reminderType: reminderType,
        leadTimeMinutes: leadTimeMinutes,
        snoozeIntervalMinutes: snoozeInterval,
      );

      final savedMed = await medicationService.addMedication(newMed);
      await loadData();

      if (savedMed.isStockLow || savedMed.currentStock <= savedMed.lowStockThreshold) {
        notificationService.scheduleStockReminder(
          id: savedMed.id.hashCode,
          medicationName: savedMed.medicationName,
          currentStock: savedMed.currentStock,
          scheduledTime: DateTime.now().add(const Duration(seconds: 2)),
          medicationId: savedMed.id,
          isCritical: savedMed.currentStock <= 2,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _scheduleSingleAlarm(Medication med, DateTime date, TimeOfDay time, String intakeLogId) async {
    final scheduledDateTime = DateTime(
      date.year, date.month, date.day, time.hour, time.minute,
    ).subtract(Duration(minutes: med.leadTimeMinutes));

    final notificationId = intakeLogId.hashCode;

    if (med.reminderType == ReminderType.alarm) {
      await notificationService.scheduleNativeAlarm(
        id: notificationId, medicationName: med.medicationName, dosage: med.dosage,
        medicationId: med.id, intakeLogId: intakeLogId,
        snoozeInterval: med.snoozeIntervalMinutes, scheduledTime: scheduledDateTime,
      );
    } else {
      await notificationService.scheduleMedicationReminder(
        id: notificationId, title: "Rappel : ${med.medicationName}",
        body: "C'est l'heure de votre prise (${med.dosage})",
        scheduledTime: scheduledDateTime, medicationId: med.id,
        intakeLogId: intakeLogId, snoozeInterval: med.snoozeIntervalMinutes, dosage: med.dosage,
      );
    }
  }

  Future<void> updateIntakeTime(String logId, TimeOfDay newTime) async {
    try {
      final logIndex = state.intakeLogs.indexWhere((l) => l.id == logId);
      if (logIndex == -1) return;
      final oldLog = state.intakeLogs[logIndex];
      final medication = state.medications.firstWhere((m) => m.id == oldLog.treatmentId);

      final oldId = logId.hashCode;
      await notificationService.cancelNotification(oldId);
      await notificationService.cancelNativeAlarm(oldId);

      await medicationService.updateIntake(logId: logId, slotTime: newTime);
      final updatedLogs = List<IntakeLog>.from(state.intakeLogs);
      updatedLogs[logIndex] = oldLog.copyWith(slotTime: newTime);
      state = state.copyWith(intakeLogs: updatedLogs);

      _scheduleSingleAlarm(medication, oldLog.intakeDate, newTime, logId);
      _updateEndOfDayBilan();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> setIntakeStatus(String logId, IntakeStatus newStatus, {bool force = false}) async {
    final logIndex = state.intakeLogs.indexWhere((l) => l.id == logId);
    if (logIndex == -1) return false;
    final log = state.intakeLogs[logIndex];
    final oldStatus = log.status;

    if (!force && newStatus != IntakeStatus.pending && oldStatus == IntakeStatus.pending) {
      final now = DateTime.now();
      final scheduledTime = DateTime(
        log.intakeDate.year, log.intakeDate.month, log.intakeDate.day,
        log.slotTime.hour, log.slotTime.minute,
      );
      final allowedStartTime = scheduledTime.subtract(const Duration(minutes: 30));
      if (now.isBefore(allowedStartTime)) {
        final formattedTime = "${log.slotTime.hour.toString().padLeft(2, '0')}h${log.slotTime.minute.toString().padLeft(2, '0')}";
        debugPrint("Prise refusée : Trop tôt (Prévue à $formattedTime)");
        return false; 
      }
    }

    try {
      await medicationService.updateIntake(
        logId: logId,
        status: newStatus.name.toUpperCase(),
        actualTakenDateTime: newStatus == IntakeStatus.taken ? DateTime.now() : null,
      );
      if (newStatus != IntakeStatus.pending) {
        final notificationId = logId.hashCode;
        await notificationService.cancelNotification(notificationId);
        await notificationService.cancelNativeAlarm(notificationId);
      }
      final updatedLogs = List<IntakeLog>.from(state.intakeLogs);
      updatedLogs[logIndex] = log.copyWith(
        status: newStatus,
        actualTakenDateTime: newStatus == IntakeStatus.taken ? DateTime.now() : null,
      );
      if (newStatus == IntakeStatus.taken && oldStatus != IntakeStatus.taken) {
        _updateLocalStock(log.treatmentId, -1);
      } else if (oldStatus == IntakeStatus.taken && newStatus != IntakeStatus.taken) {
        _updateLocalStock(log.treatmentId, 1);
      }
      state = state.copyWith(intakeLogs: updatedLogs);
      _updateEndOfDayBilan();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> toggleIntakeStatus(String logId) async {
    final logIndex = state.intakeLogs.indexWhere((l) => l.id == logId);
    if (logIndex == -1) return;
    final log = state.intakeLogs[logIndex];
    final nextStatus = log.status == IntakeStatus.taken ? IntakeStatus.pending : IntakeStatus.taken;
    await setIntakeStatus(logId, nextStatus);
  }

  void _updateEndOfDayBilan() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayLogs = state.intakeLogs.where((l) =>
    l.intakeDate.year == today.year &&
        l.intakeDate.month == today.month &&
        l.intakeDate.day == today.day
    ).toList();
    notificationService.scheduleEndOfDayReminder(todayLogs);
  }

  void _updateLocalStock(String medId, int amount) {
    if (amount == 0) return;
    final medIndex = state.medications.indexWhere((m) => m.id == medId);
    if (medIndex == -1) return;
    final updatedMeds = List<Medication>.from(state.medications);
    final med = updatedMeds[medIndex];
    final newStock = med.currentStock + amount;
    final bool locallyLow = newStock <= med.lowStockThreshold;
    updatedMeds[medIndex] = med.copyWith(currentStock: newStock, isStockLow: locallyLow);
    state = state.copyWith(medications: updatedMeds);
    if (amount < 0 && (locallyLow || med.isStockLow)) {
      notificationService.scheduleStockReminder(
        id: med.id.hashCode, medicationName: med.medicationName, currentStock: newStock,
        scheduledTime: DateTime.now().add(const Duration(seconds: 2)),
        medicationId: med.id, isCritical: newStock <= 2,
      );
    }
    notificationService.scheduleDailyStockCheck(updatedMeds);
  }
}

final medicationProvider = StateNotifierProvider<MedicationNotifier, MedicationState>((ref) {
  final authState = ref.watch(authProvider);
  
  if (authState.status != AuthStatus.authenticated) {
    return MedicationNotifier(isEmpty: true);
  }

  return MedicationNotifier();
});
