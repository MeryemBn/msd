import 'dart:async';
import 'dart:math' show min, max;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/pharmacy_provider.dart';
import '../../../core/services/location_service.dart';

class PharmacyMapScreen extends ConsumerStatefulWidget {
  const PharmacyMapScreen({super.key});

  @override
  ConsumerState<PharmacyMapScreen> createState() => _PharmacyMapScreenState();
}

class _PharmacyMapScreenState extends ConsumerState<PharmacyMapScreen> {
  maps.GoogleMapController? _mapController;
  maps.LatLng? _lastSearchPosition;
  bool _showSearchButton = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;
  bool _isSearching = false;
  Set<maps.Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    // Lancement immédiat du chargement des pharmacies et de la position
    Future.microtask(() => ref.read(pharmacyProvider.notifier).loadNearbyPharmacies());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _fmtDist(double? km) {
    if (km == null) return '';
    return km < 1 ? '${(km * 1000).round()} m' : '${km.toStringAsFixed(1)} km';
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.trim().length >= 3) _performSearch(query.trim());
      else if (query.trim().isEmpty) setState(() => _searchResults = []);
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() => _isSearching = true);
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final userPos = ref.read(pharmacyProvider).userPosition;
      final results = await ref.read(pharmacyServiceProvider).searchPlaces(query, locale, userPos);
      
      if (mounted) {
        setState(() => _searchResults = results);
      }
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _selectSuggestion(Map<String, dynamic> res) async {
    final placeId = res['place_id'];
    setState(() => _isSearching = true);
    
    final pos = await ref.read(pharmacyServiceProvider).getPlaceDetails(placeId);
    
    if (!mounted) return;
    setState(() => _isSearching = false);

    if (pos != null) {
      final target = maps.LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(maps.CameraUpdate.newLatLngZoom(target, 15));

      setState(() {
        _searchResults = [];
        _searchController.text = res['short_name'];
        _showSearchButton = false;
        _lastSearchPosition = target;
        _polylines = {}; 
      });

      ref.read(pharmacyProvider.notifier).loadNearbyPharmacies(
        lat: target.latitude,
        lng: target.longitude,
      );
    }
    FocusScope.of(context).unfocus();
  }

  void _onCameraMove(maps.CameraPosition position) {
    if (_lastSearchPosition == null) return;
    final double diff = (position.target.latitude - _lastSearchPosition!.latitude).abs() +
                         (position.target.longitude - _lastSearchPosition!.longitude).abs();
    if (diff > 0.005) {
      if (!_showSearchButton) setState(() => _showSearchButton = true);
    }
  }

  void _searchThisArea() async {
    if (_mapController == null) return;
    final region = await _mapController!.getVisibleRegion();
    final center = maps.LatLng(
      (region.northeast.latitude + region.southwest.latitude) / 2,
      (region.northeast.longitude + region.southwest.longitude) / 2,
    );
    setState(() {
      _showSearchButton = false;
      _lastSearchPosition = center;
    });
    ref.read(pharmacyProvider.notifier).loadNearbyPharmacies(lat: center.latitude, lng: center.longitude);
  }

  void _moveToUserLocation() {
    final state = ref.read(pharmacyProvider);
    if (state.userPosition != null && _mapController != null) {
      final userLatLng = maps.LatLng(state.userPosition!.latitude, state.userPosition!.longitude);
      _mapController!.animateCamera(maps.CameraUpdate.newLatLngZoom(userLatLng, 15.0));
      setState(() {
        _lastSearchPosition = userLatLng;
        _showSearchButton = false;
      });
    } else {
      ref.read(pharmacyProvider.notifier).loadNearbyPharmacies();
    }
  }

  Future<void> _drawRouteToPharmacy(double destLat, double destLng) async {
    final state = ref.read(pharmacyProvider);
    if (state.userPosition == null) return;

    final origin = maps.LatLng(state.userPosition!.latitude, state.userPosition!.longitude);
    final destination = maps.LatLng(destLat, destLng);

    final routeData = await locationService.getRouteData(origin, destination);
    if (mounted && routeData != null) {
      setState(() {
        _polylines = {
          maps.Polyline(
            polylineId: const maps.PolylineId('route_to_pharmacy'),
            points: routeData.points,
            color: const Color(0xFF2DBFAD),
            width: 5,
          ),
        };
      });

      final bounds = maps.LatLngBounds(
        southwest: maps.LatLng(
          min(origin.latitude, destination.latitude),
          min(origin.longitude, destination.longitude),
        ),
        northeast: maps.LatLng(
          max(origin.latitude, destination.latitude),
          max(origin.longitude, destination.longitude),
        ),
      );
      _mapController?.animateCamera(maps.CameraUpdate.newLatLngBounds(bounds, 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(pharmacyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // On affiche un loader plein écran tant qu'on n'a pas déterminé la position utilisateur.
    // Cela garantit que la carte démarre directement sur la position réelle de l'utilisateur
    // au lieu d'afficher Casablanca par défaut.
    if (state.userPosition == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.onDutyPharmacy),
          elevation: 0,
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          foregroundColor: isDark ? Colors.white : AppTheme.textDark,
        ),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF2DBFAD))),
      );
    }

    // Une fois la position disponible, on initialise _lastSearchPosition si ce n'est pas fait
    if (_lastSearchPosition == null) {
      _lastSearchPosition = maps.LatLng(state.userPosition!.latitude, state.userPosition!.longitude);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onDutyPharmacy),
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : AppTheme.textDark,
      ),
      body: Stack(
        children: [
          maps.GoogleMap(
            initialCameraPosition: maps.CameraPosition(
              target: maps.LatLng(state.userPosition!.latitude, state.userPosition!.longitude),
              zoom: 14.0,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: _onCameraMove,
            markers: {
              ...state.pharmacies.map((p) => maps.Marker(
                markerId: maps.MarkerId(p.id),
                position: maps.LatLng(p.latitude, p.longitude),
                onTap: () {
                  ref.read(pharmacyProvider.notifier).selectPharmacy(p);
                  _drawRouteToPharmacy(p.latitude, p.longitude);
                  _showPharmacyDetails(context);
                },
                icon: maps.BitmapDescriptor.defaultMarkerWithHue(maps.BitmapDescriptor.hueGreen),
              )),
              if (_lastSearchPosition != null)
                maps.Marker(
                  markerId: const maps.MarkerId('search_target'),
                  position: _lastSearchPosition!,
                  infoWindow: maps.InfoWindow(title: _searchController.text.isNotEmpty ? _searchController.text : "Position choisie"),
                  icon: maps.BitmapDescriptor.defaultMarkerWithHue(maps.BitmapDescriptor.hueRed),
                ),
            },
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (_) {
              if (_searchResults.isNotEmpty) setState(() => _searchResults = []);
              FocusScope.of(context).unfocus();
              setState(() => _polylines = {}); 
            },
          ),

          // Barre de recherche
          Positioned(
            top: 10, left: 15, right: 15,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: "Rechercher une ville, un lieu...",
                      hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2DBFAD)),
                      suffixIcon: _isSearching
                          ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2DBFAD))))
                          : (_searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _searchController.clear(); _searchResults = []; _polylines = {}; })) : null),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final res = _searchResults[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.place_outlined, color: Color(0xFF2DBFAD), size: 20),
                          title: Row(
                            children: [
                              Expanded(child: Text(res['short_name'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87))),
                              if (res['distance'] != null)
                                Text(_fmtDist(res['distance']), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2DBFAD))),
                            ],
                          ),
                          subtitle: Text(res['display_name'], style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                          onTap: () => _selectSuggestion(res),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Bouton "Chercher ici"
          if (_showSearchButton && _searchResults.isEmpty)
            Positioned(
              top: 75, left: 0, right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _searchThisArea,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text("Chercher les pharmacies ici"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ),

          // Bouton de localisation
          Positioned(
            right: 16, bottom: 30,
            child: FloatingActionButton(
              heroTag: 'locate_user_pharmacy',
              mini: true,
              backgroundColor: isDark ? Colors.grey[800] : Colors.white,
              onPressed: _moveToUserLocation,
              child: const Icon(Icons.my_location, color: AppTheme.primary),
            ),
          ),

          // Loader overlay (quand on rafraîchit)
          if (state.isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                ),
              ),
            ),

          // Message d'erreur
          if (state.error != null && !state.isLoading)
            Positioned(
              bottom: 100, left: 20, right: 20,
              child: Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(state.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPharmacyDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final pharmacy = ref.watch(pharmacyProvider).selectedPharmacy;
            final isFetching = ref.watch(pharmacyProvider).isFetchingDetails;
            if (pharmacy == null) return const SizedBox(height: 100);

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(pharmacy.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                        child: const Text("OUVERT", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(pharmacy.address, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                  const Divider(height: 32),
                  if (isFetching)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: [
                        if (pharmacy.phoneNumber != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => launchUrl(Uri.parse("tel:${pharmacy.phoneNumber!.replaceAll(RegExp(r'[^0-9+]'), '')}")),
                                icon: const Icon(Icons.phone),
                                label: Text("Appeler (${pharmacy.phoneNumber})"),
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              locationService.launchDirections(pharmacy.latitude, pharmacy.longitude);
                            },
                            icon: const Icon(Icons.directions),
                            label: const Text("Itinéraire"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: const BorderSide(color: AppTheme.primary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) => ref.read(pharmacyProvider.notifier).clearSelection());
  }
}
