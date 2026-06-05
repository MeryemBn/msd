class LocationDetails {
  final String address;
  final String? apartment;
  final String? floor;
  final String? entryCode;
  final double latitude; // Required by API Spec
  final double longitude; // Required by API Spec

  LocationDetails({
    required this.address,
    this.apartment,
    this.floor,
    this.entryCode,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'apartment': apartment,
      'floor': floor,
      'entryCode': entryCode, // Spec says entryCode (camelCase in some places, but let's stick to what's common in your project or spec)
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LocationDetails.fromJson(Map<String, dynamic> json) {
    return LocationDetails(
      address: json['address'],
      apartment: json['apartment'],
      floor: json['floor'],
      entryCode: json['entryCode'] ?? json['entry_code'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  LocationDetails copyWith({
    String? address,
    String? apartment,
    String? floor,
    String? entryCode,
    double? latitude,
    double? longitude,
  }) {
    return LocationDetails(
      address: address ?? this.address,
      apartment: apartment ?? this.apartment,
      floor: floor ?? this.floor,
      entryCode: entryCode ?? this.entryCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
