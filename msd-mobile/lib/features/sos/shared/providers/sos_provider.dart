import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import '../../../auth/models/auth_user.dart';
import '../models/sos_request.dart';
import '../models/sos_enums.dart';
import '../models/sos_type.dart';
import '../models/location_details.dart';
import '../models/intervention_details.dart';
import '../models/request_details.dart';
import '../services/sos_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/stripe_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/providers/auth_state.dart';
import '../../../profile/providers/profile_provider.dart';

class SosState {
  final SosRequest? currentRequest;
  final SosType? currentType;
  final List<SosRequest> myRequests;
  final List<UserProfile> foundProfessionals;
  final UserProfile? selectedProfessional;
  final double maxDistanceKm;
  final bool isLoading;
  final String? error;
  final double? estimatedPrice;

  SosState({
    this.currentRequest,
    this.currentType,
    this.myRequests = const [],
    this.foundProfessionals = const [],
    this.selectedProfessional,
    this.maxDistanceKm = 20.0,
    this.isLoading = false,
    this.error,
    this.estimatedPrice,
  });

  SosState copyWith({
    SosRequest? currentRequest,
    SosType? currentType,
    List<SosRequest>? myRequests,
    List<UserProfile>? foundProfessionals,
    Object? selectedProfessional = _undefined,
    double? maxDistanceKm,
    bool? isLoading,
    String? error,
    Object? estimatedPrice = _undefined,
  }) {
    return SosState(
      currentRequest: currentRequest ?? this.currentRequest,
      currentType: currentType ?? this.currentType,
      myRequests: myRequests ?? this.myRequests,
      foundProfessionals: foundProfessionals ?? this.foundProfessionals,
      selectedProfessional: selectedProfessional == _undefined ? this.selectedProfessional : (selectedProfessional as UserProfile?),
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      estimatedPrice: estimatedPrice == _undefined ? this.estimatedPrice : (estimatedPrice as double?),
    );
  }

  static const Object _undefined = Object();
}

class SosNotifier extends StateNotifier<SosState> {
  final Ref _ref;
  Timer? _refreshTimer;
  final Set<String> _notifiedStatusKeys = {};

  SosNotifier(this._ref) : super(SosState()) {
    _init();
  }

  void _init() {
    _ref.listen(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        loadMyRequests(silent: true);
        _startAutoRefresh();
      } else {
        _stopAutoRefresh();
        state = SosState();
      }
    }, fireImmediately: true);
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      loadMyRequests(silent: true);
    });
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<AppLocalizations> _getLocalizations() async {
    const storage = FlutterSecureStorage();
    final langCode = await storage.read(key: 'language_code') ?? 'fr';
    return await AppLocalizations.delegate.load(Locale(langCode));
  }

  void updateMaxDistance(double distance) {
    state = state.copyWith(maxDistanceKm: distance);
    searchProfessionals();
  }

  void initNewRequest(RequestDetails details, double price, SosType type) {
    state = state.copyWith(
      currentType: type,
      foundProfessionals: [],
      selectedProfessional: null,
      estimatedPrice: null,
      currentRequest: SosRequest(
        details: details,
        paymentMethod: type == SosType.teleconsult ? PaymentMethod.card : PaymentMethod.cash,
        price: price,
        status: RequestStatus.pending,
      ),
    );
    _fetchEstimationIfNeeded();
  }

  void updateInterventionType(InterventionType type) {
    final request = state.currentRequest;
    if (request == null) return;

    final updatedIntervention = request.details.interventionDetails.copyWith(
      interventionType: type,
      appointmentDateTime: type == InterventionType.sos_urgency ? null : request.details.interventionDetails.appointmentDateTime,
    );

    final updatedDetails = _updateDetailsWithIntervention(request.details, updatedIntervention);
    state = state.copyWith(currentRequest: request.copyWith(details: updatedDetails));

    if (state.selectedProfessional != null) {
      recalculatePrice();
    } else {
      _fetchEstimationIfNeeded();
    }
  }

  void updateSpecialty(Specialty specialty) {
    final request = state.currentRequest;
    if (request == null) return;

    RequestDetails? updatedDetails;
    if (request.details is DoctorDetails) {
      updatedDetails = DoctorDetails(
        interventionDetails: request.details.interventionDetails,
        specialty: specialty,
      );
    } else if (request.details is TeleconsultDetails) {
      updatedDetails = TeleconsultDetails(
        interventionDetails: request.details.interventionDetails,
        specialty: specialty,
      );
    }

    if (updatedDetails != null) {
      state = state.copyWith(currentRequest: request.copyWith(details: updatedDetails));
      if (state.selectedProfessional != null) {
        recalculatePrice();
      } else {
        _fetchEstimationIfNeeded();
      }
    }
  }

  void updateAmbulanceType(AmbulanceType type) {
    final request = state.currentRequest;
    if (request == null || request.details is! AmbulanceDetails) return;

    final updatedDetails = AmbulanceDetails(
      interventionDetails: request.details.interventionDetails,
      ambulanceType: type,
    );
    state = state.copyWith(currentRequest: request.copyWith(details: updatedDetails));
    if (state.selectedProfessional != null) {
      recalculatePrice();
    } else {
      _fetchEstimationIfNeeded();
    }
  }

  void updateAppointmentDateTime(DateTime dateTime) {
    final request = state.currentRequest;
    if (request == null) return;

    final updatedIntervention = request.details.interventionDetails.copyWith(
      appointmentDateTime: dateTime,
    );
    final updatedDetails = _updateDetailsWithIntervention(request.details, updatedIntervention);
    state = state.copyWith(currentRequest: request.copyWith(details: updatedDetails));

    if (state.selectedProfessional != null) {
      recalculatePrice();
    } else {
      _fetchEstimationIfNeeded();
    }
  }

  void updateLocation(LocationDetails location) {
    final request = state.currentRequest;
    if (request == null) return;

    final updatedIntervention = request.details.interventionDetails.copyWith(
      location: location,
    );
    final updatedDetails = _updateDetailsWithIntervention(request.details, updatedIntervention);
    state = state.copyWith(currentRequest: request.copyWith(details: updatedDetails));

    if (state.selectedProfessional != null) {
      recalculatePrice();
    } else {
      _fetchEstimationIfNeeded();
    }
  }

  void updatePaymentMethod(PaymentMethod method) {
    if (state.currentRequest == null) return;
    state = state.copyWith(
      currentRequest: state.currentRequest!.copyWith(paymentMethod: method),
    );
  }

  void selectProfessional(UserProfile pro) {
    state = state.copyWith(
      selectedProfessional: pro,
      currentRequest: state.currentRequest?.copyWith(professionalId: pro.id.toString()),
    );
    recalculatePrice();
  }

  Future<void> _fetchEstimationIfNeeded() async {
    final type = state.currentType;
    final request = state.currentRequest;

    if (type == null || request == null || state.selectedProfessional != null) return;
    if (request.details.interventionDetails.interventionType != InterventionType.sos_urgency) return;

    try {
      String? specialty;
      String? ambulanceType;
      if (request.details is DoctorDetails) specialty = (request.details as DoctorDetails).specialty.toJson();
      if (request.details is TeleconsultDetails) specialty = (request.details as TeleconsultDetails).specialty.toJson();
      if (request.details is AmbulanceDetails) ambulanceType = (request.details as AmbulanceDetails).ambulanceType.toJson();

      final avgPrice = await sosService.getAveragePrice(
        serviceType: type.apiKey,
        specialty: specialty,
        ambulanceType: ambulanceType,
        interventionMode: 'SOS_URGENCY',
      );

      if (mounted && avgPrice > 0) {
        state = state.copyWith(
          estimatedPrice: avgPrice,
          currentRequest: request.copyWith(price: avgPrice),
        );
      }
    } catch (e) {
      debugPrint("Error fetching average price: $e");
    }
  }

  Future<void> recalculatePrice() async {
    final pro = state.selectedProfessional;
    final request = state.currentRequest;
    final type = state.currentType;
    final location = request?.details.interventionDetails.location;

    if (pro == null || request == null || type == null) return;
    if (type != SosType.teleconsult && location == null) return;

    try {
      double? distanceKm;
      if (location != null && pro.latitude != null && pro.longitude != null && location.latitude != 0) {
        distanceKm = Geolocator.distanceBetween(
            location.latitude, location.longitude,
            pro.latitude!, pro.longitude!
        ) / 1000.0;
      }

      String? specialty;
      String? ambulanceType;
      if (request.details is DoctorDetails) specialty = (request.details as DoctorDetails).specialty.toJson();
      if (request.details is TeleconsultDetails) specialty = (request.details as TeleconsultDetails).specialty.toJson();
      if (request.details is AmbulanceDetails) ambulanceType = (request.details as AmbulanceDetails).ambulanceType.toJson();

      final finalPrice = await sosService.calculatePrice(
        professionalId: pro.id.toString(),
        serviceType: type.apiKey,
        specialty: specialty,
        ambulanceType: ambulanceType,
        interventionMode: request.details.interventionDetails.interventionType?.toJson() ?? 'SOS_URGENCY',
        distanceKm: distanceKm,
      );

      state = state.copyWith(
        currentRequest: request.copyWith(price: finalPrice),
      );
    } catch (e) {
      debugPrint("Error recalculating price: $e");
    }
  }

  Future<void> searchProfessionals() async {
    if (state.currentType == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      String? specialty;
      String? ambulanceType;
      final details = state.currentRequest?.details;

      if (details is DoctorDetails) {
        specialty = details.specialty.toJson();
      } else if (details is TeleconsultDetails) {
        specialty = details.specialty.toJson();
      } else if (details is AmbulanceDetails) {
        ambulanceType = details.ambulanceType.toJson();
      }

      final location = state.currentRequest?.details.interventionDetails.location;

      final pros = await sosService.searchProfessionals(
        serviceType: state.currentType!.apiKey,
        specialty: specialty,
        ambulanceType: ambulanceType,
        latitude: location?.latitude,
        longitude: location?.longitude,
        maxDistance: state.maxDistanceKm,
      );
      state = state.copyWith(foundProfessionals: pros, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  RequestDetails _updateDetailsWithIntervention(RequestDetails details, InterventionDetails intervention) {
    if (details is DoctorDetails) {
      return DoctorDetails(interventionDetails: intervention, specialty: details.specialty);
    } else if (details is NurseDetails) {
      return NurseDetails(interventionDetails: intervention);
    } else if (details is TeleconsultDetails) {
      return TeleconsultDetails(interventionDetails: intervention, specialty: details.specialty);
    } else if (details is AmbulanceDetails) {
      return AmbulanceDetails(interventionDetails: intervention, ambulanceType: (details as AmbulanceDetails).ambulanceType);
    }
    return details;
  }

  Future<void> submitRequest() async {
    if (state.currentRequest == null || state.currentType == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Si paiement par carte, on procède d'abord au paiement Stripe
      if (state.currentRequest!.paymentMethod == PaymentMethod.card) {
        final amount = state.currentRequest!.price;
        if (amount > 0) {
          final userProfile = _ref.read(profileProvider).userProfile;
          await StripeService.instance.makePayment(
            amount: amount,
            currency: 'mad',
            patientId: userProfile?.id?.toString(),
          );
        }
      }

      await sosService.createSosRequest(state.currentRequest!, state.currentType!);
      state = state.copyWith(isLoading: false);
      loadMyRequests();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> loadMyRequests({bool silent = false}) async {
    if (!silent) state = state.copyWith(isLoading: true, error: null);
    try {
      final requests = await sosService.getMySosRequests();
      requests.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
      
      await _checkStatusChanges(requests);

      state = state.copyWith(myRequests: requests, isLoading: false);
    } catch (e) {
      if (!silent) state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _checkStatusChanges(List<SosRequest> requests) async {
    final isFirstSync = _notifiedStatusKeys.isEmpty;
    final now = DateTime.now();
    final l10n = await _getLocalizations();

    for (var req in requests) {
      if (req.id == null) continue;

      final confirmedKey = "${req.id}_confirmed";
      final awaitingPaymentKey = "${req.id}_awaiting_payment";
      final onTheWayKey = "${req.id}_on_the_way";
      final inProgressKey = "${req.id}_in_progress";
      final completedKey = "${req.id}_completed";
      final rejectedKey = "${req.id}_rejected";
      final cancelledKey = "${req.id}_cancelled";

      bool isRecent = req.updatedAt == null || now.difference(req.updatedAt!).inMinutes < 15;

      if (req.status == RequestStatus.awaiting_payment && !_notifiedStatusKeys.contains(awaitingPaymentKey)) {
        if (!isFirstSync || isRecent) {
           notificationService.showInstantNotification(
            id: awaitingPaymentKey,
            title: "Demande acceptée !",
            body: "Votre demande a été acceptée par ${req.professionalFullName}. Veuillez procéder au paiement pour confirmer l'intervention.",
            type: 'sos_accepted',
          );
        }
        _notifiedStatusKeys.add(awaitingPaymentKey);
      }

      if (req.status == RequestStatus.confirmed && !_notifiedStatusKeys.contains(confirmedKey)) {
        if (!isFirstSync || isRecent) {
          final proName = req.professionalFullName.isNotEmpty ? req.professionalFullName : l10n.professional;
          notificationService.showInstantNotification(
            id: confirmedKey,
            title: l10n.notificationSosAcceptedTitle,
            body: l10n.notificationSosAcceptedBody(proName),
            type: 'sos_accepted',
          );
        }
        _notifiedStatusKeys.add(confirmedKey);
      }

      if (req.status == RequestStatus.on_the_way && !_notifiedStatusKeys.contains(onTheWayKey)) {
        if (!isFirstSync || isRecent) {
          final proName = req.professionalFullName.isNotEmpty ? req.professionalFullName : l10n.professional;
          notificationService.showInstantNotification(
            id: onTheWayKey,
            title: l10n.notificationSosOnTheWayTitle,
            body: l10n.notificationSosOnTheWayBody(proName),
            type: 'sos_status',
          );
        }
        _notifiedStatusKeys.add(onTheWayKey);
      }

      if (req.status == RequestStatus.in_progress && !_notifiedStatusKeys.contains(inProgressKey)) {
        if (!isFirstSync || isRecent) {
          final proName = req.professionalFullName.isNotEmpty ? req.professionalFullName : l10n.professional;
          final isTele = req.details is TeleconsultDetails;
          notificationService.showInstantNotification(
            id: inProgressKey,
            title: isTele ? l10n.notificationSosInProgressTitle : l10n.statusInProgress,
            body: isTele ? l10n.notificationSosInProgressBody(proName) : "$proName a démarré l'intervention.",
            type: 'sos_status',
          );
        }
        _notifiedStatusKeys.add(inProgressKey);
      }

      if (req.status == RequestStatus.completed && !_notifiedStatusKeys.contains(completedKey)) {
        if (!isFirstSync || isRecent) {
          final proName = req.professionalFullName.isNotEmpty ? req.professionalFullName : l10n.professional;
          notificationService.showInstantNotification(
            id: completedKey,
            title: "Intervention terminée",
            body: "Votre intervention avec $proName est terminée. N'oubliez pas de laisser un avis !",
            type: 'sos_status',
          );
        }
        _notifiedStatusKeys.add(completedKey);
      }

      if (req.status == RequestStatus.rejected && !_notifiedStatusKeys.contains(rejectedKey)) {
        if (!isFirstSync || isRecent) {
          final proName = req.professionalFullName;
          final body = proName.isNotEmpty
              ? l10n.notificationSosRejectedBody(proName)
              : l10n.notificationSosRejectedBodyGeneric;
          notificationService.showInstantNotification(
            id: rejectedKey,
            title: l10n.notificationSosRejectedTitle,
            body: body,
            type: 'sos_rejected',
          );
        }
        _notifiedStatusKeys.add(rejectedKey);
      }

      if (req.status == RequestStatus.cancelled && !_notifiedStatusKeys.contains(cancelledKey)) {
        if (!isFirstSync || isRecent) {
           notificationService.showInstantNotification(
            id: cancelledKey,
            title: l10n.notificationSosCancelledTitle,
            body: l10n.notificationSosCancelledByProBody,
            type: 'sos_rejected',
          );
        }
        _notifiedStatusKeys.add(cancelledKey);
      }
    }
  }

  Future<void> cancelRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedRequest = await sosService.updateSosStatus(requestId, RequestStatus.cancelled.toJson());

      final updatedList = state.myRequests.map((req) {
        return req.id == requestId ? updatedRequest : req;
      }).toList();

      state = state.copyWith(myRequests: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }
}

final sosProvider = StateNotifierProvider<SosNotifier, SosState>((ref) {
  return SosNotifier(ref);
});
