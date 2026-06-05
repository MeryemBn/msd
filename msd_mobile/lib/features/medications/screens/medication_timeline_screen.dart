import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../models/intake_status.dart';
import '../providers/medication_provider.dart';
import '../widgets/medication_card.dart';
import 'add_medication_screen.dart';
import 'medication_planning_screen.dart';
import '../widgets/medication_details_bottom_sheet.dart';
import '../../profile/widgets/chatbot_sheet.dart';

class MedicationTimelineScreen extends ConsumerStatefulWidget {
  final String? targetIntakeLogId;

  const MedicationTimelineScreen({
    super.key,
    this.targetIntakeLogId,
  });

  @override
  ConsumerState<MedicationTimelineScreen> createState() => _MedicationTimelineScreenState();
}

class _MedicationTimelineScreenState extends ConsumerState<MedicationTimelineScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  String? _highlightedId;
  final Map<String, GlobalKey> _cardKeys = {};
  bool _hasScrolled = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _highlightedId = widget.targetIntakeLogId;

    if (_highlightedId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startScrollSequence());
      _setHighlightTimer();
    }

    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _showChatbot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatbotSheet(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});

      if (_highlightedId != null && !_hasScrolled) {
        _startScrollSequence();
      }
    }
  }

  @override
  void didUpdateWidget(MedicationTimelineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.targetIntakeLogId != null && widget.targetIntakeLogId != oldWidget.targetIntakeLogId) {
      setState(() {
        _highlightedId = widget.targetIntakeLogId;
        _hasScrolled = false;
      });
      _startScrollSequence();
      _setHighlightTimer();
    }
  }

  void _setHighlightTimer() {
    Future.delayed(const Duration(seconds: 12), () {
      if (mounted) {
        setState(() {
          _highlightedId = null;
        });
      }
    });
  }

  void _startScrollSequence() async {
    if (_hasScrolled) return;

    int retry = 0;
    while (ref.read(medicationProvider).isLoading && retry < 15) {
      await Future.delayed(const Duration(milliseconds: 300));
      retry++;
    }

    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      _scrollToTarget();
    }
  }

  void _scrollToTarget() async {
    if (_highlightedId == null || _hasScrolled) return;

    final medicationState = ref.read(medicationProvider);
    final intakeLogs = medicationState.intakeLogs;

    final targetLog = intakeLogs.firstWhere(
            (l) => l.id == _highlightedId,
        orElse: () => intakeLogs.first
    );

    if (targetLog.id != _highlightedId) return;

    final targetMedId = targetLog.treatmentId;
    GlobalKey? key = _cardKeys[targetMedId];

    if (key != null && key.currentContext != null) {
      _hasScrolled = true;
      await Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOutQuart,
        alignment: 0.1,
      );
    } else {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final todayLogs = medicationState.intakeLogs.where((log) {
        return log.intakeDate.year == today.year &&
            log.intakeDate.month == today.month &&
            log.intakeDate.day == today.day;
      }).toList();

      final activeMedsToday = medicationState.medications.where((med) {
        return todayLogs.any((log) => log.treatmentId == med.id);
      }).toList();

      activeMedsToday.sort((a, b) {
        final timeA = todayLogs.where((l) => l.treatmentId == a.id)
            .map((l) => l.slotTime.hour * 60 + l.slotTime.minute)
            .reduce((min, val) => val < min ? val : min);
        final timeB = todayLogs.where((l) => l.treatmentId == b.id)
            .map((l) => l.slotTime.hour * 60 + l.slotTime.minute)
            .reduce((min, val) => val < min ? val : min);
        return timeA.compareTo(timeB);
      });

      int targetIndex = activeMedsToday.indexWhere((m) => m.id == targetMedId);

      if (targetIndex != -1) {
        _hasScrolled = true;
        double approxOffset = targetIndex * 230.0;

        await _scrollController.animateTo(
          approxOffset.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
        );

        await Future.delayed(const Duration(milliseconds: 300));
        key = _cardKeys[targetMedId];
        if (key != null && key.currentContext != null) {
          Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 400), alignment: 0.1);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final medicationState = ref.watch(medicationProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayLogs = medicationState.intakeLogs.where((log) {
      return log.intakeDate.year == today.year &&
          log.intakeDate.month == today.month &&
          log.intakeDate.day == today.day;
    }).toList();

    final activeMedsToday = medicationState.medications.where((med) {
      return todayLogs.any((log) => log.treatmentId == med.id);
    }).toList();

    activeMedsToday.sort((a, b) {
      final timeA = todayLogs.where((l) => l.treatmentId == a.id)
          .map((l) => l.slotTime.hour * 60 + l.slotTime.minute)
          .reduce((min, val) => val < min ? val : min);
      final timeB = todayLogs.where((l) => l.treatmentId == b.id)
          .map((l) => l.slotTime.hour * 60 + l.slotTime.minute)
          .reduce((min, val) => val < min ? val : min);
      return timeA.compareTo(timeB);
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l10n),
            Expanded(
              child: medicationState.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : activeMedsToday.isEmpty
                  ? _buildEmptyState(l10n)
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                itemCount: activeMedsToday.length,
                itemBuilder: (context, index) {
                  final med = activeMedsToday[index];
                  final medLogs = todayLogs.where((l) => l.treatmentId == med.id).toList();

                  medLogs.sort((a, b) =>
                      (a.slotTime.hour * 60 + a.slotTime.minute)
                          .compareTo(b.slotTime.hour * 60 + b.slotTime.minute)
                  );

                  final cardKey = _cardKeys.putIfAbsent(med.id, () => GlobalKey());

                  return MedicationCard(
                    key: cardKey,
                    medication: med,
                    dailyLogs: medLogs,
                    highlightedLogId: _highlightedId,
                    onCardTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => MedicationDetailsBottomSheet(medication: med),
                      );
                    },
                    onIntakeTapped: (logId) {
                      ref.read(medicationProvider.notifier).toggleIntakeStatus(logId);
                      if (logId == _highlightedId) {
                        setState(() => _highlightedId = null);
                      }
                    },
                    onMarkAsMissed: (logId) {
                      ref.read(medicationProvider.notifier).setIntakeStatus(logId, IntakeStatus.missed);
                    },
                    onTimeChanged: (logId, newTime) {
                      ref.read(medicationProvider.notifier).updateIntakeTime(logId, newTime);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChatbot(context),
        backgroundColor: AppTheme.primary,
        elevation: 4,
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(l10n.noMedicationsToday, style: const TextStyle(color: AppTheme.textGrey, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.myMedications, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(l10n.dayTimeline, style: const TextStyle(color: AppTheme.textGrey, fontSize: 14)),
              ],
            ),
          ),
          // Bouton Calendrier déplacé ici
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicationPlanningScreen())),
            icon: const Icon(Icons.calendar_month, color: AppTheme.primary, size: 28),
            tooltip: l10n.calendarAndTracking,
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => const AddMedicationScreen(),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(12)
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
