import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../../../services/pharmacy_service.dart';

class PharmacyState {
  final List<Pharmacy> pharmacies;
  final Pharmacy? selectedPharmacy;
  final bool isLoading;
  final bool isFetchingDetails;
  final Position? userPosition;
  final String? error;

  const PharmacyState({
    this.pharmacies = const [],
    this.selectedPharmacy,
    this.isLoading = false,
    this.isFetchingDetails = false,
    this.userPosition,
    this.error,
  });

  PharmacyState copyWith({
    List<Pharmacy>? pharmacies,
    Pharmacy? selectedPharmacy,
    bool? isLoading,
    bool? isFetchingDetails,
    Position? userPosition,
    String? error,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return PharmacyState(
      pharmacies: pharmacies ?? this.pharmacies,
      selectedPharmacy: clearSelected ? null : (selectedPharmacy ?? this.selectedPharmacy),
      isLoading: isLoading ?? this.isLoading,
      isFetchingDetails: isFetchingDetails ?? this.isFetchingDetails,
      userPosition: userPosition ?? this.userPosition,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PharmacyNotifier extends StateNotifier<PharmacyState> {
  final PharmacyService _pharmacyService;

  PharmacyNotifier(this._pharmacyService) : super(const PharmacyState());

  Future<void> loadNearbyPharmacies({double? lat, double? lng}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      double searchLat, searchLng;

      if (lat != null && lng != null) {
        searchLat = lat;
        searchLng = lng;
      } else {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          state = state.copyWith(isLoading: false, error: 'GPS désactivé');
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
          );
        } catch (e) {
          position = await Geolocator.getLastKnownPosition();
        }

        position ??= Position(
          latitude: 33.5731, longitude: -7.5898,
          timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
        );
        
        state = state.copyWith(userPosition: position);
        searchLat = position.latitude;
        searchLng = position.longitude;
      }
      
      final pharmacies = await _pharmacyService.getNearbyPharmacies(
        searchLat, searchLng, state.userPosition,
      );
      
      state = state.copyWith(
        pharmacies: pharmacies, 
        isLoading: false, 
        error: pharmacies.isEmpty ? 'Aucune pharmacie OUVERTE trouvée dans cette zone' : null
      );
      
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectPharmacy(Pharmacy pharmacy) async {
    state = state.copyWith(selectedPharmacy: pharmacy, isFetchingDetails: true);
    try {
      final phone = await _pharmacyService.getPharmacyPhoneNumber(pharmacy.id);
      if (phone != null) {
        final updated = pharmacy.copyWith(phoneNumber: phone);
        final newList = state.pharmacies.map((p) => p.id == pharmacy.id ? updated : p).toList();
        state = state.copyWith(pharmacies: newList, selectedPharmacy: updated, isFetchingDetails: false);
      } else {
        state = state.copyWith(isFetchingDetails: false);
      }
    } catch (e) {
      state = state.copyWith(isFetchingDetails: false);
    }
  }

  void clearSelection() => state = state.copyWith(clearSelected: true);
}

final pharmacyServiceProvider = Provider<PharmacyService>((ref) => PharmacyService());

final pharmacyProvider = StateNotifierProvider<PharmacyNotifier, PharmacyState>((ref) {
  final service = ref.watch(pharmacyServiceProvider);
  return PharmacyNotifier(service);
});
