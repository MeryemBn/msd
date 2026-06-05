import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../sos/shared/models/sos_request.dart';
import '../../sos/shared/models/sos_enums.dart';
import '../../profile/providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../sos/shared/models/request_details.dart';
import '../../sos/shared/models/sos_type.dart';
import '../../sos/shared/services/sos_service.dart';
import '../../sos/shared/models/review.dart' as model;
import '../models/notification_item.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/notification_history_service.dart';
import '../../../l10n/app_localizations.dart';

class ProfessionalState {
  static const Object _undefined = Object();
  final bool isOnline;
  final bool isLoading;
  final List<SosRequest> nearbyUrgencies; 
  final List<SosRequest> pendingDirectAppointments; 
  final List<SosRequest> todaysAgenda; 
  final List<SosRequest> allConfirmedMissions; 
  final List<SosRequest> missionHistory;
  final SosRequest? activeMission; 
  final Position? currentPosition;
  final Set<String> dismissedMissionIds;

  ProfessionalState({
    this.isOnline = false,
    this.isLoading = false,
    this.nearbyUrgencies = const [],
    this.pendingDirectAppointments = const [],
    this.todaysAgenda = const [],
    this.allConfirmedMissions = const [],
    this.missionHistory = const [],
    this.activeMission,
    this.currentPosition,
    this.dismissedMissionIds = const {},
  });

  ProfessionalState copyWith({
    bool? isOnline,
    bool? isLoading,
    List<SosRequest>? nearbyUrgencies,
    List<SosRequest>? pendingDirectAppointments,
    List<SosRequest>? todaysAgenda,
    List<SosRequest>? allConfirmedMissions,
    List<SosRequest>? missionHistory,
    Object? activeMission = _undefined,
    Object? currentPosition = _undefined,
    Set<String>? dismissedMissionIds,
  }) {
    return ProfessionalState(
      isOnline: isOnline ?? this.isOnline,
      isLoading: isLoading ?? this.isLoading,
      nearbyUrgencies: nearbyUrgencies ?? this.nearbyUrgencies,
      pendingDirectAppointments: pendingDirectAppointments ?? this.pendingDirectAppointments,
      todaysAgenda: todaysAgenda ?? this.todaysAgenda,
      allConfirmedMissions: allConfirmedMissions ?? this.allConfirmedMissions,
      missionHistory: missionHistory ?? this.missionHistory,
      activeMission: activeMission == _undefined ? this.activeMission : (activeMission as SosRequest?),
      currentPosition: currentPosition == _undefined ? this.currentPosition : (currentPosition as Position?),
      dismissedMissionIds: dismissedMissionIds ?? this.dismissedMissionIds,
    );
  }
}

class ProfessionalNotifier extends StateNotifier<ProfessionalState> {
  final ApiClient _apiClient;
  final Ref _ref;
  Timer? _refreshTimer;
  StreamSubscription<Position>? _positionSubscription;
  final String _dbUrl = "https://msd-mobile-21fb4-default-rtdb.europe-west1.firebasedatabase.app/";
  
  final Set<String> _notifiedRequestIds = {};
  final Set<String> _notifiedMissionStatusKeys = {};

  ProfessionalNotifier(this._apiClient, this._ref) : super(ProfessionalState()) {
    _init();
  }

  void _init() {
    debugPrint("🚀 ProfessionalNotifier: Initializing...");
    _forceImmediateSync();
    _startAutoRefresh();

    _ref.listen(profileProvider, (previous, next) {
      if (!mounted) return;
      final user = next.userProfile;
      
      if (user == null) {
        if (!next.isLoading) fullReset();
        return;
      }
      
      if (!user.isProfessional) {
        fullReset();
        return;
      }
      
      final availabilityChanged = previous?.userProfile?.isAvailable != user.isAvailable;
      final justLoggedIn = previous?.userProfile == null;

      if (justLoggedIn || availabilityChanged) {
        state = state.copyWith(isOnline: user.isAvailable);
        _checkTrackingNeeds();
        refreshAll(silent: true);
      }
    }, fireImmediately: true);
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) refreshAll(silent: true);
    });
  }

  void fullReset() {
    debugPrint("🧹 ProfessionalNotifier: Full Reset");
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _notifiedRequestIds.clear();
    _notifiedMissionStatusKeys.clear();
    if (mounted) state = ProfessionalState();
  }

  Future<void> toggleStatus(bool available) async {
    state = state.copyWith(isOnline: available);
    try {
      await _apiClient.dio.patch('/api/professional/availability', queryParameters: {'available': available});
      await _ref.read(profileProvider.notifier).loadProfile(silent: true);
      _checkTrackingNeeds();
      refreshAll(silent: true);
    } catch (e) {
      rethrow;
    }
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isTodayOrFuture(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final comparisonDate = DateTime(date.year, date.month, date.day);
    return comparisonDate.isAtSameMomentAs(today) || comparisonDate.isAfter(today);
  }

  Future<AppLocalizations> _getLocalizations() async {
    const storage = FlutterSecureStorage();
    final langCode = await storage.read(key: 'language_code') ?? 'fr';
    return await AppLocalizations.delegate.load(Locale(langCode));
  }

  Future<void> refreshAll({bool silent = false}) async {
    if (!mounted) return;
    
    final shouldShowLoading = !silent && state.nearbyUrgencies.isEmpty && state.pendingDirectAppointments.isEmpty;
    if (shouldShowLoading) state = state.copyWith(isLoading: true);

    try {
      final List<dynamic> results = await Future.wait([
        _apiClient.dio.get('/api/professional/missions').catchError((e) => Response(requestOptions: RequestOptions(path: ''), data: [])),
        state.isOnline 
          ? _apiClient.dio.get('/api/professional/eligible-requests').catchError((e) => Response(requestOptions: RequestOptions(path: ''), data: []))
          : Future.value(Response(requestOptions: RequestOptions(path: ''), data: [])),
        _apiClient.dio.get('/api/professional/pending-appointments').catchError((e) => Response(requestOptions: RequestOptions(path: ''), data: [])),
        sosService.getMyProfessionalReviews().catchError((e) => <model.Review>[]),
      ]);

      if (!mounted) return;

      final List<dynamic> missionsData = results[0].data ?? [];
      final List<dynamic> eligibleData = results[1].data ?? [];
      final List<dynamic> directData = results[2].data ?? [];
      final List<model.Review> reviewsData = results[3];

      final now = DateTime.now();

      List<SosRequest> urgencyConfirmed = [];
      List<SosRequest> confirmedDirectMissionsToday = []; 
      List<SosRequest> allConfirmed = [];
      List<SosRequest> missionHistory = [];
      SosRequest? activeMission;
      
      for (var json in missionsData) {
        try {
          final mission = SosRequest.fromApiJson(json);
          missionHistory.add(mission);
          if (mission.status == RequestStatus.cancelled || mission.status == RequestStatus.rejected) continue;
          if (state.dismissedMissionIds.contains(mission.id)) continue;
          if (mission.status == RequestStatus.on_the_way || mission.status == RequestStatus.in_progress) {
            activeMission = mission;
          } else if (mission.status == RequestStatus.confirmed || mission.status == RequestStatus.awaiting_payment) {
            allConfirmed.add(mission);
            final missionDate = mission.details.interventionDetails.appointmentDateTime ?? mission.createdAt;
            if (mission.details.interventionDetails.interventionType == InterventionType.sos_urgency) {
              if (_isTodayOrFuture(missionDate)) urgencyConfirmed.add(mission);
            } else {
              if (missionDate != null && _isToday(missionDate)) confirmedDirectMissionsToday.add(mission);
            }
          }
        } catch (_) {}
      }

      await _checkMissionStatusChanges(missionHistory);
      await _checkNewReviews(reviewsData);

      final List<SosRequest> nearbyUrgencies = [
        ...urgencyConfirmed,
        ...eligibleData.map((j) => SosRequest.fromApiJson(j)).where((r) {
          return !state.dismissedMissionIds.contains(r.id) && r.status == RequestStatus.pending;
        })
      ];
      nearbyUrgencies.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));

      final List<SosRequest> combinedAppointments = [
        ...directData
            .map((j) => SosRequest.fromApiJson(j))
            .where((r) => r.status == RequestStatus.pending)
            // FILTRE : Masquer si le jour du rendez-vous est passé
            .where((r) => _isTodayOrFuture(r.details.interventionDetails.appointmentDateTime ?? r.createdAt)),
        ...confirmedDirectMissionsToday
      ];

      final l10n = await _getLocalizations();
      for (var req in nearbyUrgencies.where((r) => r.status == RequestStatus.pending)) {
        final notifId = "sos_${req.id}";
        if (req.id != null && !notificationHistoryService.containsNotification(notifId)) {
          if (req.createdAt != null && now.difference(req.createdAt!).inMinutes < 15) {
            await notificationService.showInstantNotification(
              id: notifId,
              title: l10n.notificationNewSosTitle,
              body: l10n.notificationNewSosBody,
              type: 'sos',
            );
          }
        }
      }

      for (var req in combinedAppointments.where((r) => r.status == RequestStatus.pending)) {
        final notifId = "apt_${req.id}";
        if (req.id != null && !notificationHistoryService.containsNotification(notifId)) {
          await notificationService.showInstantNotification(
            id: notifId,
            title: l10n.notificationNewAppointmentTitle,
            body: l10n.notificationNewAppointmentBody,
            type: 'appointment',
          );
        }
      }

      if (mounted) {
        state = state.copyWith(
          nearbyUrgencies: nearbyUrgencies,
          pendingDirectAppointments: combinedAppointments,
          allConfirmedMissions: allConfirmed,
          missionHistory: missionHistory,
          activeMission: activeMission,
          isLoading: false,
        );
        _checkTrackingNeeds();
      }
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _checkMissionStatusChanges(List<SosRequest> missions) async {
    final l10n = await _getLocalizations();
    for (var mission in missions) {
      if (mission.id == null) continue;
      final cancelledKey = "cancel_${mission.id}";
      if (mission.status == RequestStatus.cancelled && !notificationHistoryService.containsNotification(cancelledKey)) {
        await notificationService.showInstantNotification(
          id: cancelledKey,
          title: l10n.notificationSosCancelledTitle,
          body: l10n.notificationSosCancelledByPatientBody,
          type: 'sos_status',
        );
      }
    }
  }

  Future<void> _checkNewReviews(List<model.Review> reviews) async {
    if (reviews.isEmpty) return;
    final l10n = await _getLocalizations();
    final now = DateTime.now();
    
    for (var review in reviews) {
      final notifId = "review_${review.id}";
      if (!notificationHistoryService.containsNotification(notifId)) {
        bool isRecent = now.difference(review.createdAt).inMinutes.abs() < 15;
        
        if (isRecent) {
          await notificationService.showInstantNotification(
            id: notifId,
            title: l10n.notificationNewRatingTitle,
            body: l10n.notificationNewRatingBody(review.patientFullName, review.rating),
            type: 'review',
          );
        } else {
          await notificationHistoryService.addTriggeredNotification(NotificationItem(
            id: notifId,
            title: l10n.notificationNewRatingTitle,
            body: l10n.notificationNewRatingBody(review.patientFullName, review.rating),
            timestamp: review.createdAt,
            type: 'review',
            isRead: true,
          ));
        }
      }
    }
  }

  Future<void> fetchMissionHistory() async {
    await refreshAll(silent: true);
  }

  void _checkTrackingNeeds() {
    if (!mounted) return;
    if (state.isOnline || state.activeMission != null) {
      _startTracking();
    } else {
      _stopTracking();
    }
  }

  Future<void> _startTracking() async {
    if (_positionSubscription != null || !mounted) return;
    await _forceImmediateSync();
    const locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);
    _positionSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((pos) {
      if (!mounted) return;
      state = state.copyWith(currentPosition: pos);
      _updateLocationOnBackend(pos);
      if (state.activeMission?.status == RequestStatus.on_the_way) _syncPositionWithFirebase(pos);
    }, onError: (error) {
      _positionSubscription?.cancel();
      _positionSubscription = null;
      _forceImmediateSync();
    });
  }

  Future<void> _forceImmediateSync() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        state = state.copyWith(currentPosition: pos);
        _updateLocationOnBackend(pos);
        // Sync avec Firebase immédiatement si en chemin
        if (state.activeMission?.status == RequestStatus.on_the_way) {
          _syncPositionWithFirebase(pos);
        }
      }
    } catch (_) {}
  }

  void _syncPositionWithFirebase(Position pos) {
    final mission = state.activeMission;
    if (mission?.id == null || !mounted) return;
    try {
      FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: _dbUrl)
          .ref('tracking/${mission!.id}')
          .set({
        'lat': pos.latitude,
        'lng': pos.longitude,
        'timestamp': ServerValue.timestamp,
        'status': mission.status.name,
      });
    } catch (_) {}
  }

  void _stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  Future<void> _updateLocationOnBackend(Position pos) async {
    try {
      await _apiClient.dio.patch('/api/professional/location', queryParameters: {'latitude': pos.latitude, 'longitude': pos.longitude});
    } catch (_) {}
  }

  Future<void> acceptRequest(SosRequest request) async {
    await _apiClient.dio.post('/api/professional/requests/${request.id}/accept');
    await refreshAll(silent: true);
  }

  Future<void> rejectRequest(String requestId) async {
    await _apiClient.dio.post('/api/professional/requests/$requestId/reject');
    await refreshAll(silent: true);
  }

  Future<void> updateStatus(RequestStatus newStatus, {String? requestId}) async {
    final id = requestId ?? state.activeMission?.id;
    if (id == null) return;
    await _apiClient.dio.patch('/api/professional/requests/$id/status', queryParameters: {'status': newStatus.name.toUpperCase()});
    if (mounted) {
      await refreshAll(silent: true);
      if (newStatus == RequestStatus.on_the_way || newStatus == RequestStatus.in_progress) await _forceImmediateSync();
    }
  }

  void removeMission(String id) {
    state = state.copyWith(dismissedMissionIds: {...state.dismissedMissionIds, id});
    refreshAll(silent: true);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}

final professionalProvider = StateNotifierProvider<ProfessionalNotifier, ProfessionalState>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProfessionalNotifier(client, ref);
});
