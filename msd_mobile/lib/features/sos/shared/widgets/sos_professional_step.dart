import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../app/app_theme.dart';
import '../providers/sos_provider.dart';
import '../models/sos_type.dart';
import '../../../auth/models/auth_user.dart';

class SosProfessionalStep extends ConsumerStatefulWidget {
  const SosProfessionalStep({super.key});

  @override
  ConsumerState<SosProfessionalStep> createState() => _SosProfessionalStepState();
}

class _SosProfessionalStepState extends ConsumerState<SosProfessionalStep> {
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sosProvider.notifier).searchProfessionals());
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitMapToMarkers();
  }

  void _fitMapToMarkers() {
    final state = ref.read(sosProvider);
    if (state.foundProfessionals.isEmpty || _mapController == null) return;

    double? minLat, maxLat, minLng, maxLng;
    for (var pro in state.foundProfessionals) {
      if (pro.latitude == null || pro.longitude == null) continue;
      if (minLat == null || pro.latitude! < minLat) minLat = pro.latitude;
      if (maxLat == null || pro.latitude! > maxLat) maxLat = pro.latitude;
      if (minLng == null || pro.longitude! < minLng) minLng = pro.longitude;
      if (maxLng == null || pro.longitude! > maxLng) maxLng = pro.longitude;
    }

    if (minLat != null && maxLat != null && minLng != null && maxLng != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          80, // padding
        ),
      );
    }
  }

  Set<Marker> _buildMarkers(List<UserProfile> professionals, UserProfile? selected, AppLocalizations l10n) {
    return professionals.where((pro) => pro.latitude != null && pro.longitude != null).map((pro) {
      final isSelected = selected?.id == pro.id;
      return Marker(
        markerId: MarkerId(pro.id?.toString() ?? pro.keycloakId),
        position: LatLng(pro.latitude!, pro.longitude!),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isSelected ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
        ),
        onTap: () {
          ref.read(sosProvider.notifier).selectProfessional(pro);
          _showProfessionalDetails(pro, l10n);
        },
      );
    }).toSet();
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint("Erreur appel: $e");
    }
  }

  void _showProfessionalDetails(UserProfile pro, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  child: Text(
                    pro.firstName?.substring(0, 1).toUpperCase() ?? 'P',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(pro.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                          if (pro.averageRating > 0)
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                Text(
                                  pro.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(" (${pro.totalReviews})", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(pro.specialty ?? pro.serviceType ?? "", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (pro.distance != null) ...[
                            const Icon(Icons.near_me, size: 14, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              "${pro.distance!.toStringAsFixed(1)} km",
                              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (pro.completedMissionsCount > 0) ...[
                            const Icon(Icons.check_circle_outline_rounded, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              "${pro.completedMissionsCount} interventions",
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (pro.statusValidation == ValidationStatus.VALIDATED)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(Icons.verified, color: Colors.blue, size: 28),
                  ),
              ],
            ),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      l10n.chooseProfessional.toUpperCase(), 
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13)
                    ),
                  ),
                ),
                if (pro.totalReviews > 0) ...[
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: IconButton(
                      onPressed: () => context.push('/professional/reviews', extra: {'id': pro.id, 'name': pro.fullName}),
                      icon: const Icon(Icons.reviews_rounded, color: Colors.amber),
                      tooltip: "Voir les avis",
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _makePhoneCall(pro.phoneNumber),
                icon: const Icon(Icons.call, size: 20),
                label: Text(l10n.call.toUpperCase()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: const BorderSide(color: AppTheme.primary, width: 1.5),
                  foregroundColor: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isTeleconsult = state.currentType == SosType.teleconsult;

    final markers = _buildMarkers(state.foundProfessionals, state.selectedProfessional, l10n);

    final patientLoc = state.currentRequest?.details.interventionDetails.location;
    final initialPos = patientLoc != null 
        ? LatLng(patientLoc.latitude!, patientLoc.longitude!)
        : const LatLng(33.5731, -7.5898);

    ref.listen(sosProvider.select((s) => s.foundProfessionals), (prev, next) {
      if (next.isNotEmpty && _mapController != null) _fitMapToMarkers();
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.chooseProfessional, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        
        if (!isTeleconsult)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.fieldBgDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ],
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.proximityRange, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${state.maxDistanceKm.toInt()} km", 
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.primary,
                    inactiveTrackColor: AppTheme.primary.withOpacity(0.1),
                    thumbColor: AppTheme.primary,
                    overlayColor: AppTheme.primary.withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: state.maxDistanceKm,
                    min: 5,
                    max: 100,
                    divisions: 19,
                    onChanged: (value) => ref.read(sosProvider.notifier).updateMaxDistance(value),
                  ),
                ),
              ],
            ),
          ),
        
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: initialPos, zoom: 12),
                    markers: markers,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: false, 
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                    style: isDark ? AppTheme.googleMapDarkStyle : null,
                  ),
                  
                  if (state.isLoading)
                    Positioned(
                      top: 16, right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
                      ),
                    ),
                  
                  if (!state.isLoading && state.foundProfessionals.isEmpty)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.03),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            decoration: BoxDecoration(
                              color: isDark ? AppTheme.cardDark : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.withOpacity(0.5)),
                                const SizedBox(height: 12),
                                Text(l10n.noProfessionalFound, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                const Text("Essayez d'élargir le rayon", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
