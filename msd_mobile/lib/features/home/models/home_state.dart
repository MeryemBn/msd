import '../../auth/models/auth_user.dart';
import '../../sos/shared/models/sos_request.dart';
import 'next_dose_info.dart';

class HomeState {
  final UserProfile? userProfile;
  final bool isLoading;
  final NextDoseInfo? nextDoseInfo;
  final bool isLastDoseConfirmed;
  final SosRequest? activeSosRequest;

  const HomeState({
    this.userProfile,
    required this.isLoading,
    this.nextDoseInfo,
    this.isLastDoseConfirmed = false,
    this.activeSosRequest,
  });

  String get patientName => userProfile?.fullName ?? 'Utilisateur';

  factory HomeState.initial() => const HomeState(
        userProfile: null,
        isLoading: true,
        nextDoseInfo: null,
        isLastDoseConfirmed: false,
        activeSosRequest: null,
      );

  HomeState copyWith({
    UserProfile? userProfile,
    bool? isLoading,
    NextDoseInfo? nextDoseInfo,
    bool? isLastDoseConfirmed,
    bool clearNextDose = false,
    SosRequest? activeSosRequest,
    bool clearActiveSos = false,
  }) {
    return HomeState(
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      nextDoseInfo: clearNextDose ? null : (nextDoseInfo ?? this.nextDoseInfo),
      isLastDoseConfirmed: isLastDoseConfirmed ?? this.isLastDoseConfirmed,
      activeSosRequest: clearActiveSos ? null : (activeSosRequest ?? this.activeSosRequest),
    );
  }
}
