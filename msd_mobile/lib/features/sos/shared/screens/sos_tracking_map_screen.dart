import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show cos, sqrt, asin, min, max;
import '../../../../l10n/app_localizations.dart';
import '../models/sos_request.dart';
import '../../../../core/services/location_service.dart';

class SosTrackingMapScreen extends StatefulWidget {
  final SosRequest request;
  const SosTrackingMapScreen({super.key, required this.request});

  @override
  State<SosTrackingMapScreen> createState() => _SosTrackingMapScreenState();
}

class _SosTrackingMapScreenState extends State<SosTrackingMapScreen> {
  final String _dbUrl = "https://msd-mobile-21fb4-default-rtdb.europe-west1.firebasedatabase.app/";
  GoogleMapController? _mapController;
  StreamSubscription<DatabaseEvent>? _trackingSubscription;
  
  LatLng? _proPosition;
  String? _distanceText;
  String? _durationText;
  bool _isFirstLoad = true;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _setupTracking();
  }

  @override
  void dispose() {
    _trackingSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _setupTracking() {
    _trackingSubscription = FirebaseDatabase.instanceFor(
      app: Firebase.app(), 
      databaseURL: _dbUrl
    ).ref('tracking/${widget.request.id}').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final now = DateTime.now();
        if (_isFirstLoad || now.difference(_lastUpdate).inMilliseconds > 2000) {
          _lastUpdate = now;
          try {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);
            final newPos = LatLng(
              (data['lat'] as num).toDouble(), 
              (data['lng'] as num).toDouble()
            );
            _updateStats(newPos);
          } catch (e) {
            debugPrint("Erreur Firebase data: $e");
          }
        }
      }
    });
  }

  Future<void> _updateStats(LatLng proPos) async {
    final interventionLoc = widget.request.details.interventionDetails.location;
    if (interventionLoc == null) return;
    final targetPos = LatLng(interventionLoc.latitude, interventionLoc.longitude);

    // Récupération des données réelles (Tracé, Distance, Durée) via Google Maps API
    final routeData = await locationService.getRouteData(proPos, targetPos);

    if (mounted) {
      setState(() {
        _proPosition = proPos;
        if (routeData != null) {
          _distanceText = routeData.distanceText;
          _durationText = routeData.durationText;
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: routeData.points,
              color: const Color(0xFF2DBFAD),
              width: 5,
            ),
          };
        }

        _markers = {
          Marker(
            markerId: const MarkerId('target'),
            position: targetPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: "Destination"),
          ),
          Marker(
            markerId: const MarkerId('pro'),
            position: proPos,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: "Professionnel"),
          ),
        };
      });

      if (_isFirstLoad && _mapController != null) {
        _fitBounds(targetPos, proPos);
        _isFirstLoad = false;
      } else if (!_isFirstLoad) {
        _mapController?.animateCamera(CameraUpdate.newLatLng(proPos));
      }
    }
  }

  void _fitBounds(LatLng p1, LatLng p2) {
    if (_mapController == null) return;
    final bounds = LatLngBounds(
      southwest: LatLng(min(p1.latitude, p2.latitude), min(p1.longitude, p2.longitude)),
      northeast: LatLng(max(p1.latitude, p2.latitude), max(p1.longitude, p2.longitude)),
    );
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80.0));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = widget.request.details.interventionDetails.location;
    final targetPos = loc != null ? LatLng(loc.latitude, loc.longitude) : const LatLng(33.5731, -7.5898);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _proPosition ?? targetPos, zoom: 14),
            onMapCreated: (c) {
              _mapController = c;
              if (isDark) _mapController!.setMapStyle(_darkMapStyle);
              if (_proPosition != null) {
                _fitBounds(targetPos, _proPosition!);
                setState(() => _isFirstLoad = false);
              }
            },
            markers: _markers.isEmpty ? {
              Marker(
                markerId: const MarkerId('target'),
                position: targetPos,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              )
            } : _markers,
            polylines: _polylines,
            zoomControlsEnabled: false,
            myLocationEnabled: false,
            mapToolbarEnabled: false,
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
            ),
          ),

          Positioned(
            bottom: 24, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: const Color(0xFF2DBFAD).withOpacity(0.1),
                        child: const Icon(Icons.person, color: Color(0xFF2DBFAD)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.request.professionalFullName.isNotEmpty ? widget.request.professionalFullName : "Professionnel", 
                                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(l10n.onTheWay, style: const TextStyle(color: Color(0xFF2DBFAD), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Material(
                        color: const Color(0xFF2DBFAD),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () async {
                            final phone = widget.request.professionalPhoneNumber;
                            if (phone != null && phone.isNotEmpty) {
                              await launchUrl(Uri.parse('tel:$phone'));
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Icons.phone, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(Icons.timer_outlined, 
                          _durationText ?? "--", 
                          l10n.estimatedTime),
                      _buildStat(Icons.directions_car_outlined, 
                          _distanceText ?? "--",
                          l10n.distance),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  static const String _darkMapStyle = '[{"elementType":"geometry","stylers":[{"color":"#242f3e"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#6b9a76"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},{"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#9ca5b3"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#746855"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#1f2835"}]},{"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#f3d19c"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#515c6d"}]},{"featureType":"water","elementType":"labels.text.stroke","stylers":[{"color":"#17263c"}]}]';
}
