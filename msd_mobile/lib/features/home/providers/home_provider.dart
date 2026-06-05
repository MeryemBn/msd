import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../../auth/services/auth_service.dart';
import '../../../services/medications_service.dart';
import '../../../services/pharmacy_service.dart';
import '../../../services/sos_service.dart';
import '../models/home_state.dart';
import '../models/next_dose_info.dart';
import '../../medications/providers/medication_provider.dart';
import '../../medications/models/intake_status.dart';
import '../../medications/models/medication.dart';

class HomeProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final AuthService authService;
  final Ref ref;

  late final MedicationsService medicationsService;
  late final SosService sosService;
  late final PharmacyService pharmacyService;

  HomeState _state = HomeState.initial();
  HomeState get state => _state;

  HomeProvider({
    required this.apiClient,
    required this.ref,
    AuthService? authService,
  }) : authService = authService ?? AuthService() {
    medicationsService = MedicationsService(apiClient);
    sosService = SosService(apiClient);
    pharmacyService = PharmacyService();

    _init();
  }

  Future<void> _init({bool keepConfirmedState = false, bool isRefreshingAfterAction = false}) async {
    _state = _state.copyWith(
      isLoading: true,
      isLastDoseConfirmed: keepConfirmedState ? _state.isLastDoseConfirmed : false,
    );
    notifyListeners();

    try {
      final accessToken = await authService.getAccessToken();
      if (accessToken == null) {
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        return;
      }

      // Parallel fetching for better performance
      final responses = await Future.wait([
        apiClient.dio.get('/api/profiles/me').catchError((e) {
          debugPrint('Profile fetch failed: $e');
          return null;
        }),
      ]);

      UserProfile? profile;
      if (responses[0] != null) {
        profile = UserProfile.fromJson(responses[0]!.data);
      }

      NextDoseInfo? nextDose;
      final medState = ref.read(medicationProvider);

      // If medications are still loading, we wait for the listener to trigger a refresh
      if (!medState.isLoading) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final todayPending = medState.intakeLogs.where((l) =>
        l.status == IntakeStatus.pending &&
            l.intakeDate.year == today.year &&
            l.intakeDate.month == today.month &&
            l.intakeDate.day == today.day
        ).toList();

        if (todayPending.isNotEmpty) {
          todayPending.sort((a, b) {
            final dateA = DateTime(a.intakeDate.year, a.intakeDate.month, a.intakeDate.day, a.slotTime.hour, a.slotTime.minute);
            final dateB = DateTime(b.intakeDate.year, b.intakeDate.month, b.intakeDate.day, b.slotTime.hour, b.slotTime.minute);
            return dateA.difference(now).abs().compareTo(dateB.difference(now).abs());
          });

          final closestLog = todayPending.first;
          final medication = medState.medications.firstWhere(
                (m) => m.id == closestLog.treatmentId,
            orElse: () => Medication(id: '', userId: '', medicationName: 'Inconnu', dosage: '', instructions: '', startDate: now, durationInDays: 0, intakeTimes: [], initialStock: 0, currentStock: 0, lowStockThreshold: 0),
          );

          if (medication.id.isNotEmpty) {
            final scheduledDateTime = DateTime(
              closestLog.intakeDate.year, closestLog.intakeDate.month, closestLog.intakeDate.day,
              closestLog.slotTime.hour, closestLog.slotTime.minute,
            );

            nextDose = NextDoseInfo(
              slotId: closestLog.id,
              medicationName: medication.medicationName,
              dosage: medication.dosage,
              formattedTime: "${closestLog.slotTime.hour.toString().padLeft(2, '0')}h${closestLog.slotTime.minute.toString().padLeft(2, '0')}",
              instruction: medication.instructions,
              scheduledDateTime: scheduledDateTime,
            );
          }
        }
      }

      _state = _state.copyWith(
        userProfile: profile,
        nextDoseInfo: nextDose,
        isLoading: false,
        isLastDoseConfirmed: false,
        clearNextDose: nextDose == null && !medState.isLoading,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('HomeProvider Critical Error: $e');
      _state = _state.copyWith(isLoading: false);
      notifyListeners();
    }
  }

  Future<void> clearNextDose() async {
    if (_state.nextDoseInfo == null) return;
    try {
      _state = _state.copyWith(isLastDoseConfirmed: true);
      notifyListeners();
      await ref.read(medicationProvider.notifier).setIntakeStatus(
        _state.nextDoseInfo!.slotId,
        IntakeStatus.taken,
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      await refresh();
    } catch (e) {
      _state = _state.copyWith(isLastDoseConfirmed: false);
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await _init(keepConfirmedState: _state.isLastDoseConfirmed);
  }
}

final homeProvider = ChangeNotifierProvider((ref) {
  final authState = ref.watch(authProvider);

  // Create provider even if not authenticated, but it won't load data
  final provider = HomeProvider(
    apiClient: apiClient,
    ref: ref,
    authService: authService,
  );

  // Re-initialize when becoming authenticated
  if (authState.status == AuthStatus.authenticated) {
    provider.refresh();
  }

  ref.listen(medicationProvider, (previous, next) {
    if (previous?.isLoading != next.isLoading || previous?.intakeLogs != next.intakeLogs) {
      provider.refresh();
    }
  });

  return provider;
});
