import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/auth_state.dart';
import '../models/medical_record.dart';

class ProfileState {
  final UserProfile? userProfile;
  final ProfessionalProfile? proProfile;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.userProfile,
    this.proProfile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfile? userProfile,
    ProfessionalProfile? proProfile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      proProfile: proProfile ?? this.proProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // --- LOGIQUE DE REDIRECTION ---

  bool get isPersonalInfoIncomplete {
    if (userProfile == null) return true;
    return (userProfile!.phoneNumber == null || userProfile!.phoneNumber!.isEmpty) ||
           (userProfile!.city == null || userProfile!.city!.isEmpty);
  }

  bool get isMedicalInfoIncomplete {
    if (userProfile == null) return true;
    if (userProfile!.isProfessional) return false;
    return userProfile!.medicalRecords.isEmpty;
  }

  bool get isProSetupIncomplete {
    if (userProfile == null || !userProfile!.isProfessional) return false;
    return userProfile!.serviceType == null || userProfile!.serviceType!.isEmpty;
  }

  bool get isDocumentsIncomplete {
    if (userProfile == null || !userProfile!.isProfessional) return false;
    return !userProfile!.hasUploadedDocuments;
  }

  bool get isWaitingForValidation => userProfile?.statusValidation == ValidationStatus.PENDING;
  bool get isRejected => userProfile?.statusValidation == ValidationStatus.REJECTED;
  bool get isValidated => userProfile?.statusValidation == ValidationStatus.VALIDATED;

  bool get isProfileComplete => userProfile?.isProfileComplete ?? false;
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ApiClient _apiClient;
  final Ref _ref;
  Timer? _refreshTimer;

  ProfileNotifier(this._apiClient, this._ref) : super(ProfileState());

  void clearProfile() {
    _refreshTimer?.cancel();
    state = ProfileState();
  }

  void startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) loadProfile(silent: true);
    });
  }

  Future<void> loadProfile({bool silent = false}) async {
    if (!mounted) return;
    final authState = _ref.read(authProvider);
    if (authState.status != AuthStatus.authenticated) return;

    if (!silent) {
      // CRUCIAL : Vider le profil AVANT le chargement pour éviter le flicker de redirection
      state = state.copyWith(isLoading: true, userProfile: null, proProfile: null, error: null);
    }

    try {
      final response = await _apiClient.dio.get('/api/profiles/me');
      final profile = UserProfile.fromJson(response.data);

      ProfessionalProfile? proProfile;
      if (profile.isProfessional) {
        proProfile = ProfessionalProfile(
          status: profile.statusValidation ?? ValidationStatus.PENDING,
          type: profile.serviceType,
          specialty: profile.specialty,
          isAvailable: profile.isAvailable,
          isSetupComplete: profile.serviceType != null,
          hasUploadedDocuments: profile.hasUploadedDocuments,
          rejectionReason: profile.rejectionReason,
        );
      }

      if (mounted) {
        state = ProfileState(userProfile: profile, proProfile: proProfile, isLoading: false);
      }
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, error: silent ? null : e.toString());
    }
  }

  Future<void> updatePersonalInfo({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String address,
    required String city,
    String? serviceType,
    String? specialty,
    String? ambulanceType,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiClient.dio.put('/api/profiles/me', data: {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'address': address,
        'city': city,
        'serviceType': serviceType,
        'specialty': specialty,
        'ambulanceType': ambulanceType,
      });
      await loadProfile(silent: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> markProfileAsComplete() async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiClient.dio.put('/api/profiles/me/complete');
      await loadProfile(silent: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addMedicalRecord(String type, String description) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiClient.dio.post('/api/profiles/me/medical-records', data: {'type': type, 'description': description});
      final newRecord = MedicalRecord.fromJson(response.data);
      if (state.userProfile != null) {
        state = state.copyWith(
          userProfile: state.userProfile!.copyWith(medicalRecords: [...state.userProfile!.medicalRecords, newRecord]),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteMedicalRecord(int recordId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _apiClient.dio.delete('/api/profiles/me/medical-records/$recordId');
      if (state.userProfile != null) {
        state = state.copyWith(
          userProfile: state.userProfile!.copyWith(medicalRecords: state.userProfile!.medicalRecords.where((r) => r.id != recordId).toList()),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProfileNotifier(client, ref);
});
