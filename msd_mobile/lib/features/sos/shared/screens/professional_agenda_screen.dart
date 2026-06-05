import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../home/providers/professional_provider.dart';
import '../../../home/widgets/pro_request_detail_sheet.dart';
import '../models/sos_request.dart';
import '../models/sos_enums.dart';
import '../models/request_details.dart';
import '../../../../l10n/app_localizations.dart';

class ProfessionalAgendaScreen extends ConsumerStatefulWidget {
  const ProfessionalAgendaScreen({super.key});

  @override
  ConsumerState<ProfessionalAgendaScreen> createState() => _ProfessionalAgendaScreenState();
}

class _ProfessionalAgendaScreenState extends ConsumerState<ProfessionalAgendaScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    Future.microtask(() => ref.read(professionalProvider.notifier).fetchMissionHistory());
  }

  List<SosRequest> _getEventsForDay(DateTime day, List<SosRequest> history) {
    return history.where((request) {
      final date = request.details.interventionDetails.appointmentDateTime ?? request.createdAt;
      if (date == null) return false;
      return isSameDay(date, day);
    }).toList();
  }

  bool _isLate(SosRequest request) {
    if (request.status != RequestStatus.confirmed) return false;
    final dt = request.details.interventionDetails.appointmentDateTime;
    if (dt == null) return false;
    return DateTime.now().isAfter(dt.add(const Duration(minutes: 30)));
  }

  String _getServiceLabel(BuildContext context, RequestDetails details) {
    final l10n = AppLocalizations.of(context)!;
    if (details is TeleconsultDetails) return l10n.teleconsultation;
    if (details is DoctorDetails) return l10n.inPersonConsultation;
    if (details is NurseDetails) return l10n.homeCare;
    if (details is AmbulanceDetails) return details.ambulanceType.getLabel(l10n);
    return details.interventionDetails.interventionType == InterventionType.sos_urgency ? "SOS Urgence" : l10n.appointment;
  }

  @override
  Widget build(BuildContext context) {
    final proState = ref.watch(professionalProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final selectedEvents = _getEventsForDay(_selectedDay ?? DateTime.now(), proState.missionHistory);
    
    selectedEvents.sort((a, b) {
      final da = a.details.interventionDetails.appointmentDateTime ?? a.createdAt!;
      final db = b.details.interventionDetails.appointmentDateTime ?? b.createdAt!;
      return da.compareTo(db);
    });

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF4F7F6),
      appBar: AppBar(
        title: Text(l10n.agenda, style: TextStyle(
          fontWeight: FontWeight.w900, 
          fontSize: 22, 
          letterSpacing: -0.5,
          color: isDark ? Colors.white : Colors.black
        )),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _calendarFormat == CalendarFormat.week ? Icons.expand_more : Icons.expand_less, 
              color: const Color(0xFF2DBFAD)
            ),
            onPressed: () => setState(() => _calendarFormat = _calendarFormat == CalendarFormat.week ? CalendarFormat.month : CalendarFormat.week),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2DBFAD)),
            onPressed: () => ref.read(professionalProvider.notifier).fetchMissionHistory(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildModernCalendar(proState.missionHistory, isDark, locale),
          _buildDayPerformanceHeader(selectedEvents, l10n, isDark, locale),
          Expanded(
            child: _buildTimeline(selectedEvents, l10n, isDark, locale),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCalendar(List<SosRequest> history, bool isDark, String locale) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black.withOpacity(0.04), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          )
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: locale == 'ar' ? 'ar' : (locale == 'fr' ? 'fr_FR' : 'en_US'),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; });
        },
        eventLoader: (day) => _getEventsForDay(day, history),
        calendarStyle: CalendarStyle(
          defaultTextStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          weekendTextStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
          todayDecoration: BoxDecoration(color: const Color(0xFF2DBFAD).withOpacity(0.1), shape: BoxShape.circle),
          todayTextStyle: const TextStyle(color: Color(0xFF2DBFAD), fontWeight: FontWeight.bold),
          selectedDecoration: const BoxDecoration(color: Color(0xFF2DBFAD), shape: BoxShape.circle),
          markerDecoration: const BoxDecoration(color: Colors.transparent),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false, 
          titleCentered: true,
          titleTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return const SizedBox();
            return _buildSmartMarkers(events.cast<SosRequest>());
          },
        ),
      ),
    );
  }

  Widget _buildSmartMarkers(List<SosRequest> events) {
    return Positioned(
      bottom: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: events.take(3).map((e) {
          Color color = Colors.blue;
          if (e.status == RequestStatus.completed) color = Colors.green;
          else if (e.status == RequestStatus.cancelled || e.status == RequestStatus.rejected) color = Colors.red;
          else if (e.details.interventionDetails.interventionType == InterventionType.sos_urgency) color = Colors.orange;
          return Container(
            width: 5, height: 5,
            margin: const EdgeInsets.symmetric(horizontal: 0.5),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDayPerformanceHeader(List<SosRequest> events, AppLocalizations l10n, bool isDark, String locale) {
    final completed = events.where((e) => e.status == RequestStatus.completed).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        children: [
          _buildStatItem(l10n.acts.toUpperCase(), "${completed.length}", Colors.blueGrey, isDark),
          const Spacer(),
          Text(
            isSameDay(_selectedDay, DateTime.now()) 
                ? l10n.today 
                : DateFormat('dd MMM', locale).format(_selectedDay ?? DateTime.now()),
            style: TextStyle(fontWeight: FontWeight.w800, color: isDark ? Colors.white38 : Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08), 
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildTimeline(List<SosRequest> events, AppLocalizations l10n, bool isDark, String locale) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(opacity: 0.5, child: Icon(Icons.event_note_outlined, size: 80, color: isDark ? Colors.white24 : Colors.grey)),
            const SizedBox(height: 16),
            Text(l10n.noMissionRecorded, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      itemCount: events.length,
      itemBuilder: (context, index) => _buildMissionCard(events[index], l10n, isDark, locale),
    );
  }

  Widget _buildMissionCard(SosRequest request, AppLocalizations l10n, bool isDark, String locale) {
    final bool isSOS = request.details.interventionDetails.interventionType == InterventionType.sos_urgency;
    final bool isTele = request.details is TeleconsultDetails;
    final bool isDone = request.status == RequestStatus.completed;
    final bool isCancelled = request.status == RequestStatus.cancelled || request.status == RequestStatus.rejected;
    final bool lateStatus = _isLate(request);
    
    Color color = isSOS ? Colors.orange : (isTele ? Colors.indigo : const Color(0xFF2DBFAD));
    if (isDone) color = Colors.green;
    if (isCancelled) color = Colors.red;
    if (lateStatus && !isCancelled) color = Colors.orange;

    final dt = request.details.interventionDetails.appointmentDateTime ?? request.createdAt;
    final timeStr = dt != null ? DateFormat('HH:mm', locale).format(dt) : "--:--";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: lateStatus && !isCancelled ? Border.all(color: Colors.orange.withOpacity(0.5)) : null,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black.withOpacity(0.02), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: InkWell(
        onTap: () => _showMissionDetails(request),
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                children: [
                  Text(timeStr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(isSOS ? "SOS" : "RDV", style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.patientFullName, 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lateStatus && !isCancelled)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.error_outline, color: Colors.orange, size: 18),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(isTele ? Icons.videocam_rounded : Icons.location_on_rounded, size: 12, color: isDark ? Colors.white38 : Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isTele ? l10n.teleconsultation : _getServiceLabel(context, request.details), 
                            style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.grey), 
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis
                          )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusIndicator(request.status, color, isDark, lateStatus),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(RequestStatus status, Color color, bool isDark, bool isLate) {
    IconData icon = Icons.schedule_rounded;
    if (status == RequestStatus.completed) icon = Icons.check_circle_rounded;
    if (status == RequestStatus.on_the_way) icon = Icons.directions_run_rounded;
    if (status == RequestStatus.cancelled || status == RequestStatus.rejected) icon = Icons.cancel;
    if (isLate && status == RequestStatus.confirmed) icon = Icons.error_outline;

    return Container(
      height: 36, width: 36,
      decoration: BoxDecoration(color: color.withOpacity(isDark ? 0.2 : 0.1), shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: color),
    );
  }

  void _showMissionDetails(SosRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProRequestDetailSheet(request: request),
    );
  }
}
