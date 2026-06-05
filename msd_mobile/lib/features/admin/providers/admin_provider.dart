import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/notification_history_service.dart';
import '../../auth/models/auth_user.dart';
import '../models/professional_review.dart';
import '../models/admin_stats.dart';
import '../../sos/shared/models/sos_request.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../../../l10n/app_localizations.dart';

class AdminState {
  final List<ProfessionalReview> pendingReviews;
  final List<ProfessionalReview> allProfessionals;
  final List<SosRequest> allRequests;
  final List<UserProfile> allPatients;
  final AdminStats stats;
  final bool isLoading;
  final String? error;

  AdminState({
    this.pendingReviews = const [],
    this.allProfessionals = const [],
    this.allRequests = const [],
    this.allPatients = const [],
    AdminStats? stats,
    this.isLoading = false,
    this.error,
  }) : stats = stats ?? AdminStats.empty();

  AdminState copyWith({
    List<ProfessionalReview>? pendingReviews,
    List<ProfessionalReview>? allProfessionals,
    List<SosRequest>? allRequests,
    List<UserProfile>? allPatients,
    AdminStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      pendingReviews: pendingReviews ?? this.pendingReviews,
      allProfessionals: allProfessionals ?? this.allProfessionals,
      allRequests: allRequests ?? this.allRequests,
      allPatients: allPatients ?? this.allPatients,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final ApiClient _apiClient;
  final Ref _ref;
  Timer? _refreshTimer;
  final Set<String> _notifiedIds = {};
  bool _isFirstSync = true;

  AdminNotifier(this._apiClient, this._ref) : super(AdminState()) {
    _init();
  }

  void _init() {
    _ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && next.isAdmin) {
        debugPrint("🔐 [ADMIN] Démarrage du polling (10s)");
        _pollAllData(); 
        _startAutoRefresh();
      } else if (next.status != AuthStatus.authenticated) {
        _stopAutoRefresh();
        clear();
      }
    }, fireImmediately: true);
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _pollAllData();
    });
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isFirstSync = true;
  }

  Future<void> _pollAllData() async {
    await Future.wait([
      loadDashboardData(silent: true),
      loadAllPatients(silent: true),
      loadAllRequests(silent: true),
    ]);
    _isFirstSync = false;
  }

  Future<AppLocalizations> _getLocalizations() async {
    const storage = FlutterSecureStorage();
    final langCode = await storage.read(key: 'language_code') ?? 'fr';
    return await AppLocalizations.delegate.load(Locale(langCode));
  }

  void clear() {
    state = AdminState();
    _notifiedIds.clear();
  }

  Future<void> loadDashboardData({bool silent = false}) async {
    if (!silent) state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _apiClient.dio.get('/api/admin/stats'),
        _apiClient.dio.get('/api/admin/pending-professionals'),
      ]);

      final stats = AdminStats.fromJson(results[0].data);
      final List<dynamic> reviewsData = results[1].data;
      final reviews = reviewsData.map((json) => ProfessionalReview.fromJson(json)).toList();
      final l10n = await _getLocalizations();

      for (var pro in reviews) {
        final key = "pro_pending_${pro.professionalInfoId}";
        if (!_notifiedIds.contains(key) && !notificationHistoryService.containsNotification(key)) {
          if (!_isFirstSync) {
            await notificationService.showInstantNotification(
              id: key,
              title: l10n.notificationAdminNewProTitle,
              body: l10n.notificationAdminNewProBody(pro.fullName),
              type: 'admin_new_pro',
            );
          }
          _notifiedIds.add(key);
        }
      }

      state = state.copyWith(stats: stats, pendingReviews: reviews, isLoading: false);
    } catch (e) {
      if (!silent) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAllProfessionals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.get('/api/admin/professionals');
      final List<dynamic> data = response.data;
      final professionals = data.map((json) => ProfessionalReview.fromJson(json)).toList();
      state = state.copyWith(allProfessionals: professionals, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAllPatients({bool silent = false}) async {
    if (!silent) state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.get('/api/admin/patients');
      final List<dynamic> data = response.data;
      final patients = data.map((json) => UserProfile.fromJson(json)).toList();
      final l10n = await _getLocalizations();
      final now = DateTime.now();

      for (var patient in patients) {
        if (patient.id == null) continue;
        final key = "new_patient_${patient.id}";
        
        if (!_notifiedIds.contains(key) && !notificationHistoryService.containsNotification(key)) {
          bool shouldNotify = !_isFirstSync;
          if (_isFirstSync && patient.createdAt != null) {
             shouldNotify = now.difference(patient.createdAt!).inHours.abs() < 24;
          }

          if (shouldNotify) {
            await notificationService.showInstantNotification(
              id: key,
              title: l10n.notificationAdminNewPatientTitle,
              body: l10n.notificationAdminNewPatientBody(patient.fullName),
              type: 'admin_new_patient',
            );
          }
          _notifiedIds.add(key);
        }
      }

      state = state.copyWith(allPatients: patients, isLoading: false);
    } catch (e) {
      if (!silent) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAllRequests({bool silent = false}) async {
    if (!silent) state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.get('/api/admin/requests');
      final List<dynamic> data = response.data;
      final requests = data.map((json) => SosRequest.fromApiJson(json)).toList();
      final l10n = await _getLocalizations();
      final now = DateTime.now();

      for (var req in requests) {
        if (req.id == null) continue;
        final key = "new_sos_${req.id}";
        if (!_notifiedIds.contains(key) && !notificationHistoryService.containsNotification(key)) {
          bool shouldNotify = !_isFirstSync;
          if (_isFirstSync && req.createdAt != null) {
            shouldNotify = now.difference(req.createdAt!).inHours.abs() < 24;
          }

          if (shouldNotify) {
            await notificationService.showInstantNotification(
              id: key,
              title: l10n.notificationAdminNewSosTitle,
              body: l10n.notificationAdminNewSosBody(req.patientFullName),
              type: 'admin_new_sos',
            );
          }
          _notifiedIds.add(key);
        }
      }

      state = state.copyWith(allRequests: requests, isLoading: false);
    } catch (e) {
      if (!silent) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> validateProfessional(int id) async {
    try {
      await _apiClient.dio.post('/api/admin/professionals/$id/validate');
      await loadDashboardData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rejectProfessional(int id, String reason) async {
    try {
      await _apiClient.dio.post(
        '/api/admin/professionals/$id/reject',
        data: reason,
      );
      await loadDashboardData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final client = ref.watch(apiClientProvider);
  return AdminNotifier(client, ref);
});
