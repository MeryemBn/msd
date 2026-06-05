import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/services/location_service.dart';
import 'sos_map_components.dart';

class FullScreenMapModal extends StatefulWidget {
  final LatLng initialPosition;
  final Function(LatLng position, String address) onConfirm;

  const FullScreenMapModal({
    super.key,
    required this.initialPosition,
    required this.onConfirm,
  });

  @override
  State<FullScreenMapModal> createState() => _FullScreenMapModalState();
}

class _FullScreenMapModalState extends State<FullScreenMapModal> {
  GoogleMapController? _mapController;
  late LatLng _markerPosition;
  final TextEditingController _searchController = TextEditingController();

  String _currentAddress = '';
  bool _isLoadingAddress = false;
  bool _isLocating = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _markerPosition = widget.initialPosition;
    _reverseGeocode(_markerPosition);
    _initUserPosition();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _initUserPosition() async {
    try {
      _userPosition = await locationService.getCurrentPosition();
    } catch (_) {}
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
      final results = await locationService.searchPlacesGoogle(query, locale, _userPosition);
      
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
    
    final pos = await locationService.getPlaceDetailsGoogle(placeId);
    
    if (!mounted) return;
    setState(() => _isSearching = false);

    if (pos != null) {
      final target = LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));

      setState(() {
        _searchResults = [];
        _searchController.text = res['short_name'];
        _markerPosition = target;
      });
      _reverseGeocode(target);
    }
    FocusScope.of(context).unfocus();
  }

  Future<void> _reverseGeocode(LatLng point) async {
    if (!mounted) return;
    setState(() => _isLoadingAddress = true);
    try {
      final addr = await locationService.getAddressFromCoordinates(point.latitude, point.longitude);
      if (mounted) setState(() => _currentAddress = addr);
    } catch (e) {
      debugPrint("Geocoding error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final pos = await locationService.getCurrentPosition();
      _userPosition = pos;
      final newLatLng = LatLng(pos.latitude, pos.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(newLatLng, 17.0));
      setState(() => _markerPosition = newLatLng);
      _reverseGeocode(newLatLng);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.gpsActivation(e.toString())), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.confirmLocation, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _markerPosition,
              zoom: 17.0,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onTap: (point) {
              setState(() {
                _markerPosition = point;
                _searchResults = [];
              });
              _reverseGeocode(point);
              FocusScope.of(context).unfocus();
            },
            markers: {
              Marker(
                markerId: const MarkerId('selected_location'),
                position: _markerPosition,
                infoWindow: InfoWindow(title: _searchController.text.isNotEmpty ? _searchController.text : l10n.confirmLocation),
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          Positioned(
            top: 10, left: 15, right: 15,
            child: Column(
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                    border: isDark ? Border.all(color: Colors.white10) : null,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: l10n.searchAddress,
                      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2DBFAD)),
                      suffixIcon: _isSearching
                          ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2DBFAD))))
                          : (_searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { _searchController.clear(); _searchResults = []; })) : null),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    constraints: const BoxConstraints(maxHeight: 280),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)],
                      border: isDark ? Border.all(color: Colors.white10) : null,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true, padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey.shade200),
                      itemBuilder: (_, i) {
                        final res = _searchResults[i];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.place_outlined, color: Color(0xFF2DBFAD), size: 20),
                          title: Row(
                            children: [
                              Expanded(child: Text(res['short_name'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
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

          Positioned(
            right: 15, bottom: 220,
            child: Column(
              children: [
                MapIconButton(icon: Icons.my_location, onTap: _getCurrentLocation, isPrimary: true, isLoading: _isLocating),
                const SizedBox(height: 12),
                MapIconButton(icon: Icons.add, onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn())),
                const SizedBox(height: 8),
                MapIconButton(icon: Icons.remove, onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut())),
              ],
            ),
          ),

          Positioned(
            left: 15, right: 15, bottom: 30,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (!isDark)
                    const BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))
                ],
                border: isDark ? Border.all(color: Colors.white10) : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoadingAddress)
                    const LinearProgressIndicator(color: Color(0xFF2DBFAD), backgroundColor: Color(0xFFE0F7F5))
                  else
                    Text(
                        _currentAddress,
                        style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
                        textAlign: TextAlign.center,
                        maxLines: 2
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onConfirm(_markerPosition, _currentAddress);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2DBFAD), padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0,
                      ),
                      child: Text(l10n.confirmLocation, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
