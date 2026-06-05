import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';

import '../providers/medication_provider.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/day_summary_widget.dart';
import '../widgets/legend_widget.dart';

class MedicationPlanningScreen extends ConsumerStatefulWidget {
  const MedicationPlanningScreen({super.key});

  @override
  ConsumerState<MedicationPlanningScreen> createState() =>
      _MedicationPlanningScreenState();
}

class _MedicationPlanningScreenState
    extends ConsumerState<MedicationPlanningScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(medicationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.planningTitle),
      ),
      body: Column(
        children: [
          const LegendWidget(),
          if (state.isLoading && state.intakeLogs.isEmpty)
             const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CalendarWidget(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    state: state,
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    onPageChanged: (focused) {
                      setState(() => _focusedDay = focused);
                      final start = DateTime(focused.year, focused.month, 1).subtract(const Duration(days: 7));
                      final end = DateTime(focused.year, focused.month + 1, 0).add(const Duration(days: 7));
                      ref.read(medicationProvider.notifier).loadLogsForRange(start, end);
                    },
                  ),
                  DaySummaryWidget(
                    state: state,
                    date: _selectedDay,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
