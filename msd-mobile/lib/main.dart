import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'app/app.dart';
import 'app/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/notification_history_service.dart';
import 'features/home/models/notification_item.dart';
import 'features/profile/providers/settings_provider.dart';

Future<void> requestPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  if (await Permission.location.isDenied) {
    await Permission.location.request();
  }
  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
  if (await Permission.systemAlertWindow.isDenied) {
    await Permission.systemAlertWindow.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Stripe
  try {
    Stripe.publishableKey = "pk_test_51Tee5oRlLK3OY9aKsXp2n7JhIwpJAQBwuecjEcqHFPIW2kzMd23ZURQjHmjhYo4zwkoJEaSferZpzD6ywqr0v78100IHWAjKAZ";
    await Stripe.instance.applySettings();
    debugPrint("✅ Stripe initialisé avec succès");
  } catch (e) {
    debugPrint("❌ Échec initialisation Stripe: $e");
  }

  // Initialisation critique de Firebase
  try {
    await Firebase.initializeApp();
    debugPrint("✅ Firebase initialisé avec succès");
  } catch (e) {
    debugPrint("❌ Échec initialisation Firebase: $e");
  }

  const storage = FlutterSecureStorage();
  final themeStr = await storage.read(key: 'theme_mode');
  final notifyStr = await storage.read(key: 'notifications_enabled');
  final langStr = await storage.read(key: 'language_code');

  final initialTheme = themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;
  final initialNotifications = notifyStr != 'false';
  final initialLocale = Locale(langStr ?? 'fr');

  await Hive.initFlutter();
  await Alarm.init();
  await requestPermissions();

  Alarm.ringStream.stream.listen((alarmSettings) async {
    debugPrint("🔔 Alarme déclenchée : ${alarmSettings.id}");
    try {
      final body = alarmSettings.notificationSettings.body;
      String intakeLogId = '';
      String cleanBody = body;
      if (body.contains('|#|')) {
        final parts = body.split('|#|');
        if (parts.length >= 3) {
          intakeLogId = parts[2].trim();
          cleanBody = parts[0].trim();
        }
      }
      await notificationHistoryService.addTriggeredNotification(NotificationItem(
        id: intakeLogId.isNotEmpty ? intakeLogId : 'alarm_${alarmSettings.id}',
        title: alarmSettings.notificationSettings.title,
        body: cleanBody,
        timestamp: DateTime.now(),
        type: 'medication',
      ));
    } catch (e) {
      debugPrint("❌ Erreur historique alarme: $e");
    }

    await Future.delayed(const Duration(milliseconds: 300));
    try {
      appRouter.go('/alarm-ring', extra: alarmSettings);
    } catch (e) {
      debugPrint("Erreur navigation alarme: $e");
    }
  });

  try {
    await notificationService.init();
    notificationService.setEnabled(initialNotifications);
  } catch (e) {
    debugPrint("Erreur init notifications: $e");
  }

  await initializeDateFormatting('fr_FR', null);

  runApp(
    ProviderScope(
      overrides: [
        settingsProvider.overrideWith((ref) => SettingsNotifier(
              initialTheme: initialTheme,
              initialNotifications: initialNotifications,
              initialLocale: initialLocale,
            )),
      ],
      child: const MsdApp(),
    ),
  );
}
