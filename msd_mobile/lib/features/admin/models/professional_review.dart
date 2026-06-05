import '../../auth/models/auth_user.dart';

class ProfessionalDocumentModel {
  final int id;
  final String documentType;
  final String filePath;
  final String fileName;
  final String ocrResult;
  final DateTime uploadedAt;

  ProfessionalDocumentModel({
    required this.id,
    required this.documentType,
    required this.filePath,
    required this.fileName,
    required this.ocrResult,
    required this.uploadedAt,
  });

  factory ProfessionalDocumentModel.fromJson(Map<String, dynamic> json) {
    return ProfessionalDocumentModel(
      id: json['id'] ?? 0,
      documentType: json['documentType'] ?? 'Inconnu',
      filePath: json['filePath'] ?? '',
      fileName: json['fileName'] ?? '',
      ocrResult: json['ocrResult'] ?? '',
      uploadedAt: json['uploadedAt'] != null 
          ? DateTime.parse(json['uploadedAt']) 
          : DateTime.now(),
    );
  }

  // URL corrigée : Garde "documents/..." et retire seulement "uploads/"
  String get fullUrl {
    if (filePath.isEmpty) return "";
    
    // 1. Normaliser les séparateurs Windows (\ vers /)
    String path = filePath.replaceAll(r'\', '/');
    
    // 2. Extraire la partie relative après le dossier racine "uploads"
    // Si path = "uploads/documents/pro3/img.png", on veut "documents/pro3/img.png"
    if (path.contains('uploads/')) {
      path = path.split('uploads/').last;
    }
    
    // 3. Nettoyer les slashs de début
    while (path.startsWith('/')) {
      path = path.substring(1);
    }
    
    return "http://192.168.1.3:8080/api/uploads/$path";
  }
}

class ProfessionalReview {
  final int professionalInfoId;
  final String firstName;
  final String lastName;
  final String email;
  final String? serviceType;
  final String? specialty;
  final String? ambulanceType;
  final ValidationStatus status;
  final List<ProfessionalDocumentModel> documents;

  ProfessionalReview({
    required this.professionalInfoId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.serviceType,
    this.specialty,
    this.ambulanceType,
    required this.status,
    required this.documents,
  });

  factory ProfessionalReview.fromJson(Map<String, dynamic> json) {
    return ProfessionalReview(
      professionalInfoId: json['professionalInfoId'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      serviceType: json['serviceType'],
      specialty: json['specialty'],
      ambulanceType: json['ambulanceType'],
      status: ValidationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ValidationStatus.PENDING,
      ),
      documents: (json['documents'] as List? ?? [])
          .map((d) => ProfessionalDocumentModel.fromJson(d))
          .toList(),
    );
  }

  String get fullName => "$firstName $lastName";
}
