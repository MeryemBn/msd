import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import '../../../../l10n/app_localizations.dart';
import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/msd_button.dart';
import '../../../../core/services/location_service.dart';
import '../providers/sos_provider.dart';
import '../../../auth/models/auth_user.dart';
import '../models/sos_request.dart';
import '../models/location_details.dart';
import '../models/request_details.dart';
import '../models/intervention_details.dart';

class ProfessionalSelectionScreen extends ConsumerStatefulWidget {
  const ProfessionalSelectionScreen({super.key});

  @override
  ConsumerState<ProfessionalSelectionScreen> createState() => _ProfessionalSelectionScreenState();
}

class _ProfessionalSelectionScreenState extends ConsumerState<ProfessionalSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sosProvider.notifier).searchProfessionals());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sosProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chooseProfessional),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.fieldBgDark : Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.proximityRange,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "${state.maxDistanceKm.toInt()} km",
                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: state.maxDistanceKm,
                  min: 5,
                  max: 100,
                  divisions: 19,
                  activeColor: AppTheme.primary,
                  onChanged: (value) {
                    ref.read(sosProvider.notifier).updateMaxDistance(value);
                  },
                ),
              ],
            ),
          ),
          
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.foundProfessionals.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noProfessionalFound,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16, color: AppTheme.textGrey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.foundProfessionals.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final pro = state.foundProfessionals[index];
                          final isSelected = state.selectedProfessional?.id == pro.id;

                          return InkWell(
                            onTap: () => ref.read(sosProvider.notifier).selectProfessional(pro),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.fieldBgDark : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppTheme.primary : (isDark ? Colors.white10 : Colors.grey.shade200),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  if (!isDark)
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF3DD6C0), Color(0xFF2DBFAD)],
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (pro.firstName != null && pro.firstName!.isNotEmpty)
                                            ? pro.firstName![0].toUpperCase()
                                            : 'P',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                pro.fullName,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                            ),
                                            if (pro.averageRating > 0)
                                              Row(
                                                children: [
                                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    pro.averageRating.toStringAsFixed(1),
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              pro.specialty ?? pro.serviceType ?? l10n.professional,
                                              style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                                            ),
                                            if (pro.completedMissionsCount > 0) ...[
                                              const SizedBox(width: 8),
                                              const Text("•", style: TextStyle(color: Colors.grey)),
                                              const SizedBox(width: 8),
                                              Text(
                                                "${pro.completedMissionsCount} interventions",
                                                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ],
                                        ),
                                        _ProRoadDistance(pro: pro),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: const Icon(Icons.check_circle, color: AppTheme.primary),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: MsdButton(
              text: l10n.confirm,
              onPressed: state.selectedProfessional != null ? () => Navigator.pop(context) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProRoadDistance extends ConsumerStatefulWidget {
  final UserProfile pro;
  const _ProRoadDistance({required this.pro});
  @override
  ConsumerState<_ProRoadDistance> createState() => _ProRoadDistanceState();
}

class _ProRoadDistanceState extends ConsumerState<_ProRoadDistance> {
  String _distance = "...";

  @override
  void initState() {
    super.initState();
    _loadDistance();
  }

  Future<void> _loadDistance() async {
    final sosState = ref.read(sosProvider);
    final location = sosState.currentRequest?.details.interventionDetails.location;
    
    if (location == null || widget.pro.latitude == null || widget.pro.longitude == null) return;
    
    final origin = maps.LatLng(location.latitude, location.longitude);
    final destination = maps.LatLng(widget.pro.latitude!, widget.pro.longitude!);
    
    final data = await locationService.getRouteData(origin, destination);
    if (mounted && data != null) {
      setState(() => _distance = data.distanceText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.directions_car, size: 12, color: AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            _distance,
            style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
