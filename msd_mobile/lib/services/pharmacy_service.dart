import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Pharmacy {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final bool isOpen;
  final double? distance;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.isOpen = false,
    this.distance,
  });

  factory Pharmacy.fromGoogleLegacy(Map<String, dynamic> json, Position? userPos) {
    final location = json['geometry']['location'];
    final double lat = (location['lat'] as num).toDouble();
    final double lng = (location['lng'] as num).toDouble();
    
    double? dist;
    if (userPos != null) {
      dist = Geolocator.distanceBetween(userPos.latitude, userPos.longitude, lat, lng) / 1000;
    }

    return Pharmacy(
      id: json['place_id'] ?? '',
      name: json['name'] ?? 'Pharmacie',
      address: json['vicinity'] ?? 'Adresse non disponible',
      latitude: lat,
      longitude: lng,
      isOpen: json['opening_hours']?['open_now'] ?? false,
      distance: dist,
    );
  }

  Pharmacy copyWith({String? phoneNumber}) {
    return Pharmacy(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isOpen: isOpen,
      distance: distance,
    );
  }
}

class PharmacyService {
  String? _cachedApiKey;

  Future<String?> _getApiKey() async {
    if (_cachedApiKey != null) return _cachedApiKey;
    try {
      final String response = await rootBundle.loadString('assets/config/maps_config.json');
      final Map<String, dynamic> data = json.decode(response);
      _cachedApiKey = data['MAPS_API_KEY'];
      return _cachedApiKey;
    } catch (e) {
      debugPrint('Error loading maps_config.json: $e');
      return null;
    }
  }

  Future<List<Pharmacy>> getNearbyPharmacies(double lat, double lng, [Position? userPos]) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) throw Exception('API Key Google manquante. Redémarrez l\'application.');

    final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
        'location=$lat,$lng'
        '&rankby=distance' 
        '&type=pharmacy'
        '&keyword=pharmacie'
        '&opennow=true'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
          final List results = data['results'] ?? [];
          return results.map((e) => Pharmacy.fromGoogleLegacy(e, userPos)).toList();
        } else {
          throw Exception(data['error_message'] ?? 'Erreur Google: ${data['status']}');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> getPharmacyPhoneNumber(String placeId) async {
    final apiKey = await _getApiKey();
    if (apiKey == null) return null;

    final url = 'https://maps.googleapis.com/maps/api/place/details/json?'
        'place_id=$placeId'
        '&fields=formatted_phone_number'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result']?['formatted_phone_number'];
      }
    } catch (e) {
      debugPrint('Error fetching phone number: $e');
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> searchPlaces(String query, String language, [Position? userPosition]) async {
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) return [];

    var url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
        'input=$query'
        '&components=country:ma'
        '&language=$language'
        '&key=$apiKey';

    if (userPosition != null) {
      url += '&origin=${userPosition.latitude},${userPosition.longitude}';
      url += '&location=${userPosition.latitude},${userPosition.longitude}&radius=50000';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' || data['status'] == 'ZERO_RESULTS') {
          final List predictions = data['predictions'] ?? [];
          final results = predictions.map((p) {
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

          if (userPosition != null) {
            results.sort((a, b) {
              if (a['distance'] == null) return 1;
              if (b['distance'] == null) return -1;
              return (a['distance'] as double).compareTo(b['distance'] as double);
            });
          }
          return results;
        }
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
    return [];
  }

  Future<Position?> getPlaceDetails(String placeId) async {
    final apiKey = await _getApiKey();
    if (apiKey == null) return null;

    final url = 'https://maps.googleapis.com/maps/api/place/details/json?'
        'place_id=$placeId'
        '&fields=geometry'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final loc = data['result']['geometry']['location'];
          return Position(
            latitude: (loc['lat'] as num).toDouble(),
            longitude: (loc['lng'] as num).toDouble(),
            timestamp: DateTime.now(),
            accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
          );
        }
      }
    } catch (e) {
      debugPrint('Details error: $e');
    }
    return null;
  }
}
