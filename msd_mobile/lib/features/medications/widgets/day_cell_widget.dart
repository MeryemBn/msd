import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';
import '../models/intake_status.dart';
import '../providers/medication_provider.dart';

class DayCellWidget extends StatelessWidget {
  final DateTime day;
  final MedicationState state;
  final bool isSelected;
  final bool isToday;

  const DayCellWidget({
    super.key,
    required this.day,
    required this.state,
    this.isSelected = false,
    this.isToday = false,
  });

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final normalizedDay = _normalize(day);
    final today = _normalize(DateTime.now());
    final isFuture = normalizedDay.isAfter(today);

    // 1. Déterminer s'il y a au moins un médicament actif aujourd'hui
    bool hasAnyActiveMed = state.medications.any((med) {
      final start = _normalize(med.startDate);
      final end = start.add(Duration(days: med.durationInDays - 1));
      return (normalizedDay.isAtSameMomentAs(start) || normalizedDay.isAfter(start)) &&
             (normalizedDay.isAtSameMomentAs(end) || normalizedDay.isBefore(end));
    });

    // 2. Calcul du score journalier
    final dayLogs = state.intakeLogs.where((log) => _normalize(log.intakeDate) == normalizedDay).toList();
    Color? statusPointColor;
    
    if (dayLogs.isNotEmpty && !isFuture) {
      final takenCount = dayLogs.where((l) => l.status == IntakeStatus.taken).length;
      if (takenCount == dayLogs.length) {
        statusPointColor = Colors.green;
      } else if (takenCount > 0) {
        statusPointColor = AppTheme.orangeAccent;
      } else {
        statusPointColor = AppTheme.redAccent;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppTheme.primary.withOpacity(0.15) 
            : (isToday ? AppTheme.primary.withOpacity(0.08) : Colors.transparent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasAnyActiveMed)
            Positioned(
              bottom: 12,
              left: 2,
              right: 2,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isFuture 
                      ? (isDark ? Colors.white12 : Colors.grey.shade300) 
                      : AppTheme.primary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

          // Chiffre du jour
          Positioned(
            top: 4,
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w500,
                color: isFuture 
                    ? (isDark ? Colors.white24 : Colors.grey.shade400) 
                    : (isSelected ? AppTheme.primary : theme.colorScheme.onSurface),
                fontSize: 14,
              ),
            ),
          ),

          // Point de Score
          if (statusPointColor != null)
            Positioned(
              bottom: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusPointColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
