import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/models/auth_user.dart';
import '../models/professional_review.dart';
import '../models/admin_stats.dart';
import '../../sos/shared/models/sos_request.dart';

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

  AdminNotifier(this._apiClient) : super(AdminState());

  void clear() {
    state = AdminState();
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _apiClient.dio.get('/api/admin/stats'),
        _apiClient.dio.get('/api/admin/pending-professionals'),
      ]);

      final stats = AdminStats.fromJson(results[0].data);
      final List<dynamic> reviewsData = results[1].data;
      final reviews = reviewsData.map((json) => ProfessionalReview.fromJson(json)).toList();

      state = state.copyWith(
        stats: stats,
        pendingReviews: reviews,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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

  Future<void> loadAllPatients() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.get('/api/admin/patients');
      final List<dynamic> data = response.data;
      final patients = data.map((json) => UserProfile.fromJson(json)).toList();
      state = state.copyWith(allPatients: patients, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAllRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.dio.get('/api/admin/requests');
      final List<dynamic> data = response.data;
      final requests = data.map((json) => SosRequest.fromApiJson(json)).toList();
      state = state.copyWith(allRequests: requests, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final client = ref.watch(apiClientProvider);
  return AdminNotifier(client);
});
