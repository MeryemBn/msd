import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';

class SosDateTimePicker extends StatelessWidget {
  final DateTime? value;
  final Function(DateTime) onDateTimeChanged;

  const SosDateTimePicker({
    super.key,
    required this.value,
    required this.onDateTimeChanged,
  });

  Future<void> _selectDate(BuildContext context, AppLocalizations l10n) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark 
              ? const ColorScheme.dark(
                  primary: Color(0xFF2DBFAD),
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E1E1E),
                )
              : const ColorScheme.light(
                  primary: Color(0xFF2DBFAD),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final newDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        value?.hour ?? 12,
        value?.minute ?? 0,
      );
      onDateTimeChanged(newDateTime);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()),
    );
    if (picked != null) {
      final now = value ?? DateTime.now();
      final newDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      onDateTimeChanged(newDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appointmentDate,
          style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, l10n),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 20, color: Color(0xFF2DBFAD)),
                const SizedBox(width: 12),
                Text(
                  value != null ? DateFormat.yMMMMd(locale).format(value!) : l10n.chooseDate,
                  style: TextStyle(color: value != null ? (isDark ? Colors.white70 : Colors.black87) : Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.desiredTime,
          style: TextStyle(color: isDark ? Colors.white60 : Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectTime(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: Color(0xFF2DBFAD)),
                const SizedBox(width: 12),
                Text(
                  value != null ? DateFormat('HH:mm').format(value!) : '--:--',
                  style: TextStyle(color: value != null ? (isDark ? Colors.white70 : Colors.black87) : Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
