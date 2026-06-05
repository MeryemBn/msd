import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import 'time_slot_widget.dart';
import '../models/medication.dart';
import '../models/intake_log.dart';
import '../models/intake_status.dart';

class MedicationCard extends StatefulWidget {
  final Medication medication;
  final List<IntakeLog> dailyLogs;
  final Function(String) onIntakeTapped;
  final Function(String)? onMarkAsMissed;
  final Function(String, TimeOfDay)? onTimeChanged;
  final VoidCallback? onCardTap;
  final String? highlightedLogId;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.dailyLogs,
    required this.onIntakeTapped,
    this.onMarkAsMissed,
    this.onTimeChanged,
    this.onCardTap,
    this.highlightedLogId,
  });

  @override
  State<MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _highlightController;
  late Animation<double> _borderOpacity;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _borderOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(_highlightController);

    _checkHighlight();
  }

  void _checkHighlight() {
    if (widget.highlightedLogId != null &&
        widget.dailyLogs.any((l) => l.id == widget.highlightedLogId)) {
      _highlightController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(MedicationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedLogId != null &&
        widget.highlightedLogId != oldWidget.highlightedLogId) {
      _checkHighlight();
    }
  }

  @override
  void dispose() {
    _highlightController.dispose();
    super.dispose();
  }

  bool _isTooEarly(IntakeLog log, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final intakeDay = DateTime(log.intakeDate.year, log.intakeDate.month, log.intakeDate.day);
    
    if (intakeDay.isBefore(today)) return false;
    
    final scheduledTime = DateTime(
      log.intakeDate.year, log.intakeDate.month, log.intakeDate.day,
      log.slotTime.hour, log.slotTime.minute,
    );
    
    final allowedStartTime = scheduledTime.subtract(const Duration(minutes: 30));
    return now.isBefore(allowedStartTime);
  }

  bool _isLate(IntakeLog log, DateTime now) {
    final scheduledTime = DateTime(
      log.intakeDate.year, log.intakeDate.month, log.intakeDate.day,
      log.slotTime.hour, log.slotTime.minute,
    );
    return log.status == IntakeStatus.pending &&
        now.isAfter(scheduledTime.add(const Duration(minutes: 30)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    int taken = widget.dailyLogs.where((l) => l.status == IntakeStatus.taken).length;
    int total = widget.dailyLogs.length;

    final endDate = widget.medication.startDate.add(Duration(days: widget.medication.durationInDays - 1));
    final remainingDays = endDate.difference(DateTime.now()).inDays + 1;

    String formattedDate = DateFormat.MMMd(locale).format(endDate);
    final bool isStockLow = widget.medication.isStockLow;
    final bool isCritical = widget.medication.currentStock <= 2;

    return AnimatedBuilder(
      animation: _borderOpacity,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onCardTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _borderOpacity.value > 0
                    ? AppTheme.primary.withOpacity(_borderOpacity.value)
                    : (isDark ? Colors.white10 : Colors.grey.shade100),
                width: _borderOpacity.value > 0 ? 2.5 : 1.0,
              ),
              boxShadow: [
                if (!isDark || _borderOpacity.value > 0)
                  BoxShadow(
                    color: _borderOpacity.value > 0
                        ? AppTheme.primary.withOpacity(0.15 * _borderOpacity.value)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.medication.medicationName,
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold, 
                        color: isDark ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${widget.medication.dosage} • ${widget.medication.instructions}",
                      style: TextStyle(
                        fontSize: 12, 
                        color: isDark ? Colors.white70 : AppTheme.textGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(isDark ? 0.15 : 0.08), 
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            remainingDays > 0 
                                ? l10n.until(formattedDate) + " (${l10n.daysRemaining(remainingDays)})"
                                : l10n.finishesToday,
                            style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isStockLow)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isCritical ? AppTheme.redAccent : AppTheme.orangeAccent).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${isCritical ? l10n.criticalStock : l10n.lowStock} : ${l10n.unitsRemaining(widget.medication.currentStock)}",
                              style: TextStyle(fontSize: 10, color: isCritical ? AppTheme.redAccent : AppTheme.orangeAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100, 
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$taken/$total', 
                  style: TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? Colors.white70 : AppTheme.textGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              children: widget.dailyLogs.map((log) {
                final isHighlighted = widget.highlightedLogId == log.id;

                final tooEarly = _isTooEarly(log, now);
                final lateStatus = _isLate(log, now);
                final effectivelyMissed = log.status == IntakeStatus.missed;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: TimeSlotWidget(
                            label: _getLabel(log.slotTime, l10n),
                            time: "${log.slotTime.hour.toString().padLeft(2, '0')}:${log.slotTime.minute.toString().padLeft(2, '0')}",
                            icon: _getIcon(log.slotTime),
                            taken: log.status == IntakeStatus.taken,
                            isMissed: effectivelyMissed,
                            isTooEarly: tooEarly,
                            isLate: lateStatus,
                            onTap: () => _handleUnifiedTap(context, log, tooEarly, lateStatus, l10n),
                          ),
                        ),
                        if (isHighlighted)
                          Positioned(
                            top: -6,
                            right: -6,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white, 
                                  width: 2.5,
                                ),
                                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 4)],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getLabel(TimeOfDay time, AppLocalizations l10n) {
    if (time.hour < 11) return l10n.morning;
    if (time.hour < 16) return l10n.noon;
    if (time.hour < 21) return l10n.evening;
    return l10n.bedtime;
  }

  IconData _getIcon(TimeOfDay time) {
    if (time.hour < 11) return Icons.wb_sunny_outlined;
    if (time.hour < 16) return Icons.wb_cloudy_outlined;
    if (time.hour < 21) return Icons.nights_stay_outlined;
    return Icons.bed_outlined;
  }

  void _handleUnifiedTap(BuildContext context, IntakeLog log, bool tooEarly, bool lateStatus, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    l10n.actionFor(widget.medication.medicationName),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  if (tooEarly)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        l10n.tooEarly,
                        style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    )
                  else if (lateStatus)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        l10n.lateStatus,
                        style: TextStyle(color: Colors.orange.shade700, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
            if (log.status != IntakeStatus.taken)
              ListTile(
                leading: Icon(Icons.check_circle, color: tooEarly ? Colors.grey : Colors.green),
                title: Text(
                  l10n.markAsTaken,
                  style: TextStyle(color: tooEarly ? Colors.grey : null),
                ),
                onTap: tooEarly ? null : () {
                  widget.onIntakeTapped(log.id);
                  Navigator.pop(context);
                },
              ),
            if (log.status != IntakeStatus.missed)
              ListTile(
                leading: Icon(Icons.cancel, color: tooEarly ? Colors.grey : Colors.red),
                title: Text(
                  l10n.markAsMissed,
                  style: TextStyle(color: tooEarly ? Colors.grey : null),
                ),
                onTap: tooEarly ? null : () {
                  if (widget.onMarkAsMissed != null) widget.onMarkAsMissed!(log.id);
                  Navigator.pop(context);
                },
              ),
            if (log.status == IntakeStatus.pending)
              ListTile(
                leading: const Icon(Icons.access_time_filled, color: AppTheme.primary),
                title: Text(l10n.reschedule),
                onTap: () async {
                  Navigator.pop(context);
                  final newTime = await showTimePicker(context: context, initialTime: log.slotTime);
                  if (newTime != null && widget.onTimeChanged != null) {
                    widget.onTimeChanged!(log.id, newTime);
                  }
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
