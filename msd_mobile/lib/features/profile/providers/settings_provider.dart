import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/notification_service.dart';

class SettingsState {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final Locale locale;

  SettingsState({
    required this.themeMode,
    required this.notificationsEnabled,
    required this.locale,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    Locale? locale,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final _storage = const FlutterSecureStorage();

  SettingsNotifier({
    required ThemeMode initialTheme,
    required bool initialNotifications,
    required Locale initialLocale,
  }) : super(SettingsState(
          themeMode: initialTheme,
          notificationsEnabled: initialNotifications,
          locale: initialLocale,
        )) {
    notificationService.setEnabled(initialNotifications);
  }

  Future<void> toggleTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = state.copyWith(themeMode: mode);
    await _storage.write(key: 'theme_mode', value: isDark ? 'dark' : 'light');
  }

  Future<void> toggleNotifications(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _storage.write(key: 'notifications_enabled', value: enabled.toString());
    notificationService.setEnabled(enabled);
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    await _storage.write(key: 'language_code', value: locale.languageCode);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  // Ce provider est surchargé dans main.dart, mais on définit une structure par défaut
  return SettingsNotifier(
    initialTheme: ThemeMode.light,
    initialNotifications: true,
    initialLocale: const Locale('fr'),
  );
});
