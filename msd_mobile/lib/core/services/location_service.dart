import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteData {
  final List<LatLng> points;
  final String distanceText;
  final String durationText;
  final int durationValue; // in seconds

  RouteData({
    required this.points,
    required this.distanceText,
    required this.durationText,
    required this.durationValue,
  });
}

class LocationService {
  String? _cachedApiKey;

  Future<String?> _getApiKey() async {
    if (_cachedApiKey != null) return _cachedApiKey;
    try {
      final String response = await rootBundle.loadString('assets/config/maps_config.json');
      final data = await json.decode(response);
      _cachedApiKey = data['MAPS_API_KEY'];
      return _cachedApiKey;
    } catch (e) {
      debugPrint('Error loading maps_config.json: $e');
      return null;
    }
  }

  Future<void> launchDirections(double lat, double lng) async {
    final Uri url = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint("Error launching directions: $e");
    }
  }

  Future<Position> getCurrentPosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('L\'autorisation de localisation est nécessaire.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Les permissions de localisation sont bloquées.');
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street ?? ""}, ${place.postalCode ?? ""} ${place.locality ?? ""}".trim().replaceAll(RegExp(r'^, |, $'), '');
      }
      return "Adresse introuvable";
    } catch (e) {
      return "Erreur d'adresse";
    }
  }

  /// Recherche avec distance grâce au paramètre 'origin'
  Future<List<Map<String, dynamic>>> searchPlacesGoogle(String query, String language, [Position? userPosition]) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) return [];

    String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
        'input=$query'
        '&components=country:ma'
        '&language=$language'
        '&key=$apiKey';
    
    if (userPosition != null) {
      url += '&origin=${userPosition.latitude},${userPosition.longitude}';
      url += '&location=${userPosition.latitude},${userPosition.longitude}&radius=50000'; // Biais local
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
          final List predictions = data['predictions'] ?? [];
          return predictions.map((p) {
            final double? distKm = p['distance_meters'] != null 
                ? (p['distance_meters'] as num).toDouble() / 1000 
                : null;
            
            return {
              'display_name': p['description'],
              'short_name': p['structured_formatting']['main_text'],
              'place_id': p['place_id'],
              'distance': distKm,
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('Google Search error: $e');
    }
    return [];
  }

  Future<Position?> getPlaceDetailsGoogle(String placeId) async {
    final apiKey = await _getApiKey();
    if (apiKey == null) return null;
    final url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final loc = data['result']['geometry']['location'];
          return Position(
            latitude: (loc['lat'] as num).toDouble(),
            longitude: (loc['lng'] as num).toDouble(),
            timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
          );
        }
      }
    } catch (e) {
      debugPrint('Google Details error: $e');
    }
    return null;
  }

  Future<RouteData?> getRouteData(LatLng origin, LatLng destination) async {
    final apiKey = await _getApiKey();
    if (apiKey == null) return null;

    final url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          final polyline = route['overview_polyline']['points'];
          final points = _decodePolyline(polyline);
          
          return RouteData(
            points: points,
            distanceText: leg['distance']['text'],
            durationText: leg['duration']['text'],
            durationValue: leg['duration']['value'],
          );
        }
      }
    } catch (e) {
      debugPrint('Directions error: $e');
    }
    return null;
  }

  // Backwards compatibility
  Future<List<LatLng>> getRoutePolyline(LatLng origin, LatLng destination) async {
    final data = await getRouteData(origin, destination);
    return data?.points ?? [];
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}

final locationService = LocationService();
