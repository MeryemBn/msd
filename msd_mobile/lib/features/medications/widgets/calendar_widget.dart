import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';


import '../providers/medication_provider.dart';
import 'day_cell_widget.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime)? onPageChanged;
  final MedicationState state;

  const CalendarWidget({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    this.onPageChanged,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    const double dayHeight = 48.0;
    final locale = Localizations.localeOf(context).toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (Theme.of(context).brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: focusedDay,
        rowHeight: dayHeight,
        locale: locale,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        
        sixWeekMonthsEnforced: false,
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
        ),

        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
          weekendStyle: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (_, day, __) => DayCellWidget(day: day, state: state),
          selectedBuilder: (_, day, __) => DayCellWidget(day: day, state: state, isSelected: true),
          todayBuilder: (_, day, __) => DayCellWidget(day: day, state: state, isToday: true),
        ),
      ),
    );
  }
}
