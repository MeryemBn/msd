import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../models/intake_log.dart';
import '../models/intake_status.dart';
import '../providers/medication_provider.dart';

class DaySummaryWidget extends ConsumerWidget {
  final MedicationState state;
  final DateTime? date;

  const DaySummaryWidget({
    super.key,
    required this.state,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (date == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isPastDay = date!.isBefore(today);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    final dayLogs = state.intakeLogs.where((log) {
      return log.intakeDate.year == date!.year &&
          log.intakeDate.month == date!.month &&
          log.intakeDate.day == date!.day;
    }).toList();

    dayLogs.sort((a, b) =>
        (a.slotTime.hour * 60 + a.slotTime.minute)
            .compareTo(b.slotTime.hour * 60 + b.slotTime.minute)
    );

    final takenCount = dayLogs.where((l) => l.status == IntakeStatus.taken).length;
    final totalCount = dayLogs.length;

    String formattedDate = DateFormat.MMMEd(locale).format(date!);
    if (locale == 'fr') {
       formattedDate = DateFormat('EEEE d MMMM', 'fr_FR').format(date!);
       formattedDate = formattedDate[0].toUpperCase() + formattedDate.substring(1);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$takenCount/$totalCount",
                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          if (dayLogs.isEmpty)
            Text(l10n.noMedsForDay, style: const TextStyle(color: AppTheme.textGrey))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dayLogs.length,
              itemBuilder: (context, index) {
                final log = dayLogs[index];

                final medIndex = state.medications.indexWhere((m) => m.id == log.treatmentId);
                if (medIndex == -1) return const SizedBox.shrink();

                final med = state.medications[medIndex];

                final intakeDateTime = DateTime(date!.year, date!.month, date!.day, log.slotTime.hour, log.slotTime.minute);
                
                final allowedStartTime = intakeDateTime.subtract(const Duration(minutes: 30));
                
                final bool isTooEarly = !isPastDay && now.isBefore(allowedStartTime);
                
                final bool canModify = !isTooEarly && log.status == IntakeStatus.pending;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: canModify ? () => _showActionMenu(context, ref, log, med.medicationName, l10n) : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          _buildStatusIcon(log.status, isTooEarly),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    med.medicationName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isTooEarly ? Colors.grey : null,
                                    )
                                ),
                                Text("${log.slotTime.hour.toString().padLeft(2, '0')}:${log.slotTime.minute.toString().padLeft(2, '0')}",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                              ],
                            ),
                          ),
                          _buildStatusText(log.status, isPastDay, isTooEarly, l10n),
                          if (canModify) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.edit_note, size: 18, color: AppTheme.primary),
                          ]
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(IntakeStatus status, bool isTooEarly) {
    if (isTooEarly && status == IntakeStatus.pending) {
      return const Icon(Icons.lock_outline, color: Colors.grey, size: 22);
    }
    switch (status) {
      case IntakeStatus.taken: return const Icon(Icons.check_circle, color: Colors.green, size: 22);
      case IntakeStatus.missed: return const Icon(Icons.cancel, color: Colors.red, size: 22);
      default: return const Icon(Icons.radio_button_unchecked, color: AppTheme.textGrey, size: 22);
    }
  }

  Widget _buildStatusText(IntakeStatus status, bool isPastDay, bool isTooEarly, AppLocalizations l10n) {
    if (status == IntakeStatus.taken) return Text(l10n.legendTaken, style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500));
    if (status == IntakeStatus.missed) return Text(l10n.legendMissed, style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w500));

    if (isTooEarly) return Text(l10n.statusPlanned, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500));

    return Text(l10n.statusPending, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontWeight: FontWeight.w500));
  }

  void _showActionMenu(BuildContext context, WidgetRef ref, IntakeLog log, String medName, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(l10n.regularizeTitle(medName), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(l10n.markAsTaken),
              onTap: () {
                ref.read(medicationProvider.notifier).setIntakeStatus(log.id, IntakeStatus.taken);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: Text(l10n.markAsMissed),
              onTap: () {
                ref.read(medicationProvider.notifier).setIntakeStatus(log.id, IntakeStatus.missed);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
