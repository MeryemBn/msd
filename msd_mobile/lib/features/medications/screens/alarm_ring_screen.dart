import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';

class AlarmRingScreen extends ConsumerStatefulWidget {
  final AlarmSettings alarmSettings;
  const AlarmRingScreen({super.key, required this.alarmSettings});

  @override
  ConsumerState<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends ConsumerState<AlarmRingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late int snoozeMinutes;
  String intakeLogId = '';

  Timer? _autoSnoozeTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _parseMetadata();

    _autoSnoozeTimer = Timer(const Duration(seconds: 60), () {
      if (mounted) {
        debugPrint("⏰ Auto-snooze déclenché après 60s");
        snoozeAlarm();
      }
    });
  }

  void _parseMetadata() {
    try {
      final body = widget.alarmSettings.notificationSettings.body;
      if (body.contains('|#|')) {
        final parts = body.split('|#|');
        if (parts.length >= 3) {
          snoozeMinutes = int.tryParse(parts[1].trim()) ?? 10;
          intakeLogId = parts[2].trim();
        }
      }
    } catch (e) {
      debugPrint(" Erreur parsing metadata: $e");
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _autoSnoozeTimer?.cancel();
    super.dispose();
  }

  Future<void> snoozeAlarm() async {
    _autoSnoozeTimer?.cancel();
    await Alarm.stop(widget.alarmSettings.id);
    await Alarm.set(
      alarmSettings: widget.alarmSettings.copyWith(
        dateTime: DateTime.now().add(Duration(minutes: snoozeMinutes)),
      ),
    );

    if (mounted) {
      context.go('/medications');
    }
  }

  Future<void> stopAlarm() async {
    _autoSnoozeTimer?.cancel();
    await Alarm.stop(widget.alarmSettings.id);
    if (mounted) {
      if (intakeLogId.isNotEmpty) {
        context.go('/medications?intakeLogId=$intakeLogId');
      } else {
        context.go('/medications');
      }
    }
  }

  String get formattedTime {
    final dt = widget.alarmSettings.dateTime;
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fullBody = widget.alarmSettings.notificationSettings.body;
    final displayBody = fullBody.contains('|#|') 
        ? fullBody.split('|#|')[0].trim() 
        : fullBody.split('\n')[0];

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primary.withOpacity(0.1),
                      border: Border.all(
                          color: AppTheme.primary, width: 3),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      size: 70,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  formattedTime,
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  widget.alarmSettings.notificationSettings.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  displayBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onBackground.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 60),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: snoozeAlarm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(
                          color: AppTheme.primary, width: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.snooze,
                        color: AppTheme.primary),
                    label: Text(
                      l10n.snooze(snoozeMinutes),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: stopAlarm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      l10n.confirmTake,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
