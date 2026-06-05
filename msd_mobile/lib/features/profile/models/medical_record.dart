class MedicalRecord {
  final Long? id;
  final Long? patientId;
  final String type;
  final String description;
  final String? severity;
  final DateTime? diagnosedAt;

  MedicalRecord({
    this.id,
    this.patientId,
    required this.type,
    required this.description,
    this.severity,
    this.diagnosedAt,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) => MedicalRecord(
        id: json['id'],
        patientId: json['patientId'],
        type: json['type'] ?? '',
        description: json['description'] ?? '',
        severity: json['severity'],
        diagnosedAt: json['diagnosedAt'] != null 
            ? DateTime.parse(json['diagnosedAt']) 
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'type': type,
        'description': description,
        'severity': severity,
        'diagnosedAt': diagnosedAt?.toIso8601String(),
      };
}

typedef Long = int;
