import '../../profile/models/medical_record.dart';

enum ValidationStatus {
  PENDING,
  VALIDATED,
  REJECTED
}

class SignupRequest {
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String password;
  final String role;

  const SignupRequest({
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'password': password,
    'role': role,
  };
}

class LoginRequest {
  final String username;
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}

class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int refreshExpiresIn;
  final String tokenType;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.tokenType,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
    accessToken: json['accessToken'] ?? '',
    refreshToken: json['refreshToken'] ?? '',
    expiresIn: json['expiresIn'] ?? 0,
    refreshExpiresIn: json['refreshExpiresIn'] ?? 0,
    tokenType: json['tokenType'] ?? 'Bearer',
  );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn,
    'refreshExpiresIn': refreshExpiresIn,
    'tokenType': tokenType,
  };
}

class RefreshRequest {
  final String refreshToken;

  const RefreshRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}

class ChangePasswordRequest {
  final String newPassword;

  const ChangePasswordRequest({required this.newPassword});

  Map<String, dynamic> toJson() => {'newPassword': newPassword};
}

class ProfessionalProfile {
  final int? id;
  final ValidationStatus status;
  final bool isSetupComplete;
  final bool hasUploadedDocuments;
  final String? type;
  final String? specialty;
  final bool isAvailable;
  final double averageRating;
  final int totalReviews;
  final int completedMissionsCount;
  final String? rejectionReason;

  const ProfessionalProfile({
    this.id,
    required this.status,
    this.isSetupComplete = false,
    this.hasUploadedDocuments = false,
    this.type,
    this.specialty,
    this.isAvailable = false,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.completedMissionsCount = 0,
    this.rejectionReason,
  });

  factory ProfessionalProfile.fromJson(Map<String, dynamic> json) {
    return ProfessionalProfile(
      id: json['id'],
      status: ValidationStatus.values.firstWhere(
        (e) => e.name == json['statusValidation'] || e.name == json['status'],
        orElse: () => ValidationStatus.PENDING,
      ),
      isSetupComplete: json['isSetupComplete'] ?? (json['type'] != null),
      hasUploadedDocuments: json['hasUploadedDocuments'] ?? false,
      type: json['type']?.toString() ?? json['serviceType']?.toString(),
      specialty: json['specialty']?.toString(),
      isAvailable: json['isAvailable'] ?? false,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      completedMissionsCount: json['completedMissionsCount'] ?? 0,
      rejectionReason: json['rejectionReason'] ?? json['rejection_reason'],
    );
  }
}

class UserProfile {
  final int? id;
  final String keycloakId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final bool isProfileComplete;
  final String? serviceType;
  final String? specialty;
  final String? ambulanceType;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final bool isProfessional;
  final bool isAvailable;
  final bool hasUploadedDocuments;
  final ValidationStatus? statusValidation;
  final String? rejectionReason;
  final List<MedicalRecord> medicalRecords;
  final double averageRating;
  final int totalReviews;
  final int completedMissionsCount;

  const UserProfile({
    this.id,
    required this.keycloakId,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.address,
    this.city,
    this.isProfileComplete = false,
    this.serviceType,
    this.specialty,
    this.ambulanceType,
    this.latitude,
    this.longitude,
    this.distance,
    this.isProfessional = false,
    this.isAvailable = false,
    this.hasUploadedDocuments = false,
    this.statusValidation,
    this.rejectionReason,
    this.medicalRecords = const [],
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.completedMissionsCount = 0,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    keycloakId: json['keycloakId'] ?? '',
    firstName: json['firstName'],
    lastName: json['lastName'],
    email: json['email'],
    phoneNumber: json['phoneNumber'],
    address: json['address'],
    city: json['city'],
    isProfileComplete: json['isProfileComplete'] ?? false,
    serviceType: json['serviceType'],
    specialty: json['specialty'],
    ambulanceType: json['ambulanceType'],
    latitude: json['latitude']?.toDouble(),
    longitude: json['longitude']?.toDouble(),
    distance: json['distance']?.toDouble(),
    isProfessional: json['isProfessional'] ?? false,
    isAvailable: json['isAvailable'] ?? false,
    hasUploadedDocuments: json['hasUploadedDocuments'] ?? false,
    statusValidation: json['statusValidation'] != null 
        ? ValidationStatus.values.firstWhere((e) => e.name == json['statusValidation']) 
        : null,
    rejectionReason: json['rejectionReason'] ?? json['rejection_reason'],
    medicalRecords: (json['medicalRecords'] as List? ?? [])
        .map((i) => MedicalRecord.fromJson(i))
        .toList(),
    averageRating: (json['averageRating'] ?? 0.0).toDouble(),
    totalReviews: json['totalReviews'] ?? 0,
    completedMissionsCount: json['completedMissionsCount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'keycloakId': keycloakId,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phoneNumber': phoneNumber,
    'address': address,
    'city': city,
    'isProfileComplete': isProfileComplete,
    'serviceType': serviceType,
    'specialty': specialty,
    'ambulanceType': ambulanceType,
    'latitude': latitude,
    'longitude': longitude,
    'distance': distance,
    'isProfessional': isProfessional,
    'isAvailable': isAvailable,
    'hasUploadedDocuments': hasUploadedDocuments,
    'statusValidation': statusValidation?.name,
    'rejectionReason': rejectionReason,
    'medicalRecords': medicalRecords.map((i) => i.toJson()).toList(),
    'averageRating': averageRating,
    'totalReviews': totalReviews,
    'completedMissionsCount': completedMissionsCount,
  };

  String get fullName => '$firstName $lastName'.trim().isNotEmpty 
      ? '$firstName $lastName'.trim() 
      : 'Utilisateur';

  UserProfile copyWith({
    int? id,
    String? keycloakId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    String? city,
    bool? isProfileComplete,
    String? serviceType,
    String? specialty,
    String? ambulanceType,
    double? latitude,
    double? longitude,
    double? distance,
    bool? isProfessional,
    bool? isAvailable,
    bool? hasUploadedDocuments,
    ValidationStatus? statusValidation,
    String? rejectionReason,
    List<MedicalRecord>? medicalRecords,
    double? averageRating,
    int? totalReviews,
    int? completedMissionsCount,
  }) {
    return UserProfile(
      id: id ?? this.id,
      keycloakId: keycloakId ?? this.keycloakId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      serviceType: serviceType ?? this.serviceType,
      specialty: specialty ?? this.specialty,
      ambulanceType: ambulanceType ?? this.ambulanceType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      isProfessional: isProfessional ?? this.isProfessional,
      isAvailable: isAvailable ?? this.isAvailable,
      hasUploadedDocuments: hasUploadedDocuments ?? this.hasUploadedDocuments,
      statusValidation: statusValidation ?? this.statusValidation,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      medicalRecords: medicalRecords ?? this.medicalRecords,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      completedMissionsCount: completedMissionsCount ?? this.completedMissionsCount,
    );
  }
}
