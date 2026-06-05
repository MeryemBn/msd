import 'dart:convert';
import 'package:alarm/alarm.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_router.dart';
import '../../features/medications/models/medication.dart';
import '../../features/medications/models/intake_log.dart';
import '../../features/medications/models/intake_status.dart';
import '../../features/home/models/notification_item.dart';
import 'notification_history_service.dart';


Future<AppLocalizations> _getLocalizations() async {
  const storage = FlutterSecureStorage();
  final langCode = await storage.read(key: 'language_code') ?? 'fr';
  return await AppLocalizations.delegate.load(Locale(langCode));
}

// ============================================
// HANDLERS TOP-LEVEL (obligatoire pour background isolate)
// ============================================

@pragma('vm:entry-point')
void _notificationBackgroundHandler(NotificationResponse response) {
  debugPrint("📬 Background action: ${response.actionId} | id: ${response.id}");
  _handleNotificationAction(response, isBackground: true);
}

@pragma('vm:entry-point')
void _notificationForegroundHandler(NotificationResponse response) {
  debugPrint("Foreground action: ${response.actionId} | id: ${response.id}");
  _handleNotificationAction(response, isBackground: false);
}

Future<void> _handleNotificationAction(NotificationResponse response, {required bool isBackground}) async {
  final payload = response.payload;
  if (payload == null) {
    debugPrint(" Payload null, action ignorée");
    return;
  }

  try {
    final data = jsonDecode(payload);
    
    // Notifications professionnel (nouvelle demande ou avis)
    if (data['type'] == 'sos' || data['type'] == 'appointment') {
      appRouter.go('/');
      return;
    }

    if (data['type'] == 'review') {
      appRouter.push('/professional/reviews');
      return;
    }

    // Notifications patient (statut SOS)
    if (data['type'] == 'sos_status' || data['type'] == 'sos_accepted') {
      appRouter.go('/requests');
      return;
    }

    final intakeLogId = data['intakeLogId'] as String? ?? '';
    final snoozeInterval = data['snoozeInterval'] as int? ?? 10;
    final medicationId = data['medicationId'] as String? ?? '';
    final medicationName = data['medicationName'] as String? ?? '';
    final dosage = data['dosage'] as String? ?? '';

    final l10n = await _getLocalizations();

    // Enregistrement dans l'historique au moment de l'interaction pour les notifications simples
    if (response.actionId != 'snooze') {
      notificationHistoryService.addTriggeredNotification(NotificationItem(
        id: intakeLogId.isNotEmpty ? intakeLogId : 'notif_${response.id}',
        title: l10n.notificationMedicationTitle(medicationName),
        body: l10n.notificationMedicationBody(dosage),
        timestamp: DateTime.now(),
        type: 'medication',
        medicationName: medicationName, // AJOUT DU NOM DU MÉDICAMENT
      ));
    }

    switch (response.actionId) {
      case 'snooze':
        final snoozeTime = DateTime.now().add(Duration(minutes: snoozeInterval));
        debugPrint(" Snooze programmé pour $medicationName dans $snoozeInterval min");

        notificationService.scheduleMedicationReminder(
          id: intakeLogId.hashCode.abs() % 100000,
          medicationName: medicationName,
          dosage: dosage,
          scheduledTime: snoozeTime,
          medicationId: medicationId,
          snoozeInterval: snoozeInterval,
          intakeLogId: intakeLogId,
        );
        break;

      case 'confirm':
        debugPrint(" Confirmation pour intakeLogId: $intakeLogId");
        if (intakeLogId.isNotEmpty) {
          appRouter.go('/medications?intakeLogId=$intakeLogId');
        } else {
          appRouter.go('/medications');
        }
        break;

      default:
        debugPrint(" Tap notification pour intakeLogId: $intakeLogId");
        if (intakeLogId.isNotEmpty) {
          appRouter.go('/medications?intakeLogId=$intakeLogId');
        } else {
          appRouter.go('/medications');
        }
        break;
    }
  } catch (e, stackTrace) {
    debugPrint(" Erreur action notification: $e");
    debugPrint("Stack: $stackTrace");
  }
}

// ============================================
// SERVICE NOTIFICATION
// ============================================

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isEnabled = true;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      cancelAll();
    }
  }

  Future<void> init() async {
    tz.initializeTimeZones();
    _initTimezone();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _notificationForegroundHandler,
      onDidReceiveBackgroundNotificationResponse: _notificationBackgroundHandler,
    );

    debugPrint(" NotificationService initialisé");
  }

  Future<void> initHistoryForUser(String userId) async {
    await notificationHistoryService.initForUser(userId);
    debugPrint(" Historique initialisé pour l'utilisateur: $userId");
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    final alarms = await Alarm.getAlarms();
    for (var alarm in alarms) {
      await Alarm.stop(alarm.id);
    }
    debugPrint(" Toutes les notifications et alarmes annulées");
  }

  void _initTimezone() {
    final offsetHours = DateTime.now().timeZoneOffset.inHours;
    const Map<int, String> offsetToIana = {
      0: 'Europe/London', 1: 'Africa/Casablanca', 2: 'Europe/Paris',
      3: 'Europe/Moscow', 4: 'Asia/Dubai', 5: 'Asia/Karachi',
      6: 'Asia/Dhaka', 7: 'Asia/Bangkok', 8: 'Asia/Shanghai',
      9: 'Asia/Tokyo', 10: 'Australia/Sydney', -1: 'Atlantic/Azores',
      -2: 'Atlantic/South_Georgia', -3: 'America/Sao_Paulo',
      -4: 'America/New_York', -5: 'America/New_York', -6: 'America/Chicago',
      -7: 'America/Denver', -8: 'America/Los_Angeles',
    };
    final ianaName = offsetToIana[offsetHours] ?? 'UTC';
    try {
      tz.setLocalLocation(tz.getLocation(ianaName));
      debugPrint(" Fuseau horaire: $ianaName");
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
      debugPrint(" Fuseau horaire UTC fallback");
    }
  }

  // ============================================
  // ALARMES NATIVES (plein écran, sonnerie)
  // ============================================

  Future<void> scheduleNativeAlarm({
    required int id,
    required String medicationName,
    required String dosage,
    required String medicationId,
    required String intakeLogId,
    required int snoozeInterval,
    required DateTime scheduledTime,
  }) async {
    if (!_isEnabled) return;
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint(" Alarme ignorée (heure passée): $medicationName");
      return;
    }

    final l10n = await _getLocalizations();
    final alarmId = id.abs() % 100000;
    final String hiddenMetadata = "|#|$snoozeInterval|#|$intakeLogId";

    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: scheduledTime,
      assetAudioPath: 'assets/alarm_sound.mp3',
      loopAudio: true,
      vibrate: true,
      volumeSettings: VolumeSettings.fixed(
        volume: null,
        volumeEnforced: false,
      ),
      notificationSettings: NotificationSettings(
        title: l10n.notificationMedicationTitle(medicationName),
        body: '${l10n.notificationMedicationBody(dosage)}$hiddenMetadata',
        stopButton: l10n.cancel,
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
    debugPrint(" Alarme native programmée: $medicationName à ${scheduledTime.toIso8601String()} (ID: $alarmId)");
  }

  Future<void> cancelNativeAlarm(int id, {String? intakeLogId}) async {
    final alarmId = id.abs() % 100000;
    await Alarm.stop(alarmId);
    if (intakeLogId != null) {
      await notificationHistoryService.removeNotification(intakeLogId);
    }
    debugPrint(" Alarme native annulée: ID $alarmId");
  }

  // ============================================
  // NOTIFICATIONS LOCALES (rappels silencieux)
  // ============================================

  Future<void> cancelNotification(int id, {String? intakeLogId}) async {
    final notifId = id.abs() % 100000;
    await _notificationsPlugin.cancel(notifId);
    if (intakeLogId != null) {
      await notificationHistoryService.removeNotification(intakeLogId);
    }
    debugPrint(" Notification annulée: ID $notifId");
  }

  /// ANNULATION COMPLÈTE d'un rappel (notification + alarme + historique)
  Future<void> cancelMedicationReminder(String intakeLogId) async {
    final id = intakeLogId.hashCode.abs() % 100000;
    await cancelNotification(id, intakeLogId: intakeLogId);
    await cancelNativeAlarm(id, intakeLogId: intakeLogId);
    debugPrint(" Rappel complet annulé pour intakeLogId: $intakeLogId");
  }

  Future<void> scheduleMedicationReminder({
    required int id,
    required DateTime scheduledTime,
    required String medicationId,
    required int snoozeInterval,
    String? medicationName,
    String? dosage,
    String? title, // Fallback si pas de médicament
    String? body,  // Fallback si pas de médicament
    String intakeLogId = '',
  }) async {
    if (!_isEnabled) {
      debugPrint(" Service désactivé, rappel ignoré");
      return;
    }

    final scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);
    if (scheduledTZ.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint(" Rappel ignoré (heure passée)");
      return;
    }

    final l10n = await _getLocalizations();
    final notifId = id.abs() % 100000;

    final String displayTitle = medicationName != null 
        ? l10n.notificationMedicationTitle(medicationName) 
        : (title ?? '');
    final String displayBody = dosage != null 
        ? l10n.notificationMedicationBody(dosage) 
        : (body ?? '');

    final payload = jsonEncode({
      'medicationId': medicationId,
      'medicationName': medicationName ?? '',
      'dosage': dosage ?? '',
      'intakeLogId': intakeLogId,
      'snoozeInterval': snoozeInterval,
    });

    await _notificationsPlugin.zonedSchedule(
      notifId,
      displayTitle,
      displayBody,
      scheduledTZ,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'msd_reminders',
          'Rappels Médicaments',
          channelDescription: 'Notifications de rappel de prise de médicaments',
          importance: Importance.high,
          priority: Priority.high,
          fullScreenIntent: true,
          playSound: true,
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'confirm',
              l10n.notificationActionConfirm,
              showsUserInterface: true,
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              'snooze',
              l10n.notificationActionSnooze(snoozeInterval),
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    debugPrint(" Notification programmée: $displayTitle à ${scheduledTime.toIso8601String()} (ID: $notifId, intakeLogId: $intakeLogId)");
  }

  // ============================================
  // NOTIFICATIONS IMMÉDIATES (SOS, Rendez-vous Pro, Reviews)
  // ============================================

  Future<void> showInstantNotification({
    required String id,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? payload,
  }) async {
    if (!_isEnabled) return;

    final notifId = id.hashCode.abs() % 100000;

    final finalPayload = {
      if (payload != null) ...payload,
      'type': type,
      'id': id,
    };

    await _notificationsPlugin.show(
      notifId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'msd_professional_alerts',
          'Alertes Professionnels',
          channelDescription: 'Notifications pour les nouvelles demandes SOS, rendez-vous et avis',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          fullScreenIntent: true,
        ),
      ),
      payload: jsonEncode(finalPayload),
    );

    // Sauvegarde dans l'historique
    await notificationHistoryService.addTriggeredNotification(NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      medicationName: payload?['medicationName'], // Tenter de récupérer si présent
    ));
  }

  // ============================================
  // RAPPEL DE FIN DE JOURNÉE
  // ============================================

  Future<void> scheduleEndOfDayReminder([List<IntakeLog>? todayLogs]) async {
    if (!_isEnabled) return;
    if (todayLogs == null || todayLogs.isEmpty) return;

    final hasPending = todayLogs.any((log) =>
    log.status == IntakeStatus.pending || log.status == IntakeStatus.missed
    );

    if (!hasPending) {
      await _notificationsPlugin.cancel(999);
      debugPrint(" Pas de prises en attente, rappel 23h annulé");
      return;
    }

    final l10n = await _getLocalizations();
    await scheduleMedicationReminder(
      id: 999,
      title: l10n.notificationEndOfDayTitle,
      body: l10n.notificationEndOfDayBody,
      scheduledTime: _getTodayAt23h(),
      medicationId: '',
      snoozeInterval: 0,
    );
  }

  DateTime _getTodayAt23h() {
    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, 23, 0);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  // ============================================
  // RAPPELS DE STOCK
  // ============================================

  Future<void> scheduleStockReminder({
    required int id,
    required String medicationName,
    required int currentStock,
    required DateTime scheduledTime,
    required String medicationId,
    required bool isCritical,
    bool isDaily = false,
  }) async {
    if (!_isEnabled) return;

    final scheduledTZ = tz.TZDateTime.from(scheduledTime, tz.local);
    if (scheduledTZ.isBefore(tz.TZDateTime.now(tz.local))) return;

    final l10n = await _getLocalizations();
    final notifId = id.abs() % 100000;

    final title = isCritical 
        ? l10n.notificationStockUrgentTitle(medicationName) 
        : l10n.notificationStockLowTitle(medicationName);
    final body = l10n.notificationStockBody(currentStock);

    await _notificationsPlugin.zonedSchedule(
      notifId,
      title,
      body,
      scheduledTZ,
      NotificationDetails(
        android: AndroidNotificationDetails(
          isCritical ? 'msd_stock_critical' : 'msd_stock_low',
          isCritical ? 'Stock Critique' : 'Stock Faible',
          importance: isCritical ? Importance.max : Importance.high,
          priority: isCritical ? Priority.max : Priority.high,
          color: isCritical ? const Color(0xFFFF5252) : const Color(0xFFE8A048),
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: jsonEncode({'medicationId': medicationId, 'type': 'stock', 'medicationName': medicationName}),
    );
  }

  Future<void> scheduleDailyStockCheck(List<Medication> medications) async {
    if (!_isEnabled) return;
    final now = DateTime.now();
    final tomorrow9am = DateTime(now.year, now.month, now.day, 9, 0).add(const Duration(days: 1));

    for (var med in medications) {
      if (med.currentStock <= med.lowStockThreshold) {
        await scheduleStockReminder(
          id: (med.id.hashCode + 1).abs(),
          medicationName: med.medicationName,
          currentStock: med.currentStock,
          scheduledTime: tomorrow9am,
          medicationId: med.id,
          isCritical: med.currentStock <= 2,
          isDaily: true,
        );
      } else {
        await _notificationsPlugin.cancel((med.id.hashCode + 1).abs() % 100000);
      }
    }
  }

  Future<void> cancelStockReminders(int baseId, {String? medicationId}) async {
    final id = baseId.abs() % 100000;
    await _notificationsPlugin.cancel(id);
    await _notificationsPlugin.cancel(id + 1);
    if (medicationId != null) {
      await notificationHistoryService.removeNotification(medicationId);
    }
  }
}

final notificationService = NotificationService();
