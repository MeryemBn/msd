class AdminStats {
  final int totalPatients;
  final int totalProfessionals;
  final int pendingValidations;
  final int totalSosRequests;
  final int completedMissions;
  final Map<String, int> requestsByService;
  final Map<String, int> professionalsByStatus;

  AdminStats({
    required this.totalPatients,
    required this.totalProfessionals,
    required this.pendingValidations,
    required this.totalSosRequests,
    required this.completedMissions,
    required this.requestsByService,
    required this.professionalsByStatus,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    // Normalisation des clés en majuscules pour éviter les mismatches (ex: doctor vs DOCTOR)
    final rawRequests = json['requestsByService'] as Map<String, dynamic>? ?? {};
    final Map<String, int> normalizedRequests = {};
    rawRequests.forEach((key, value) {
      normalizedRequests[key.toUpperCase()] = (value as num).toInt();
    });

    // Si le backend renvoie 0 en total général mais a des détails par service, on recalcule
    int total = json['totalSosRequests'] ?? 0;
    if (total == 0 && normalizedRequests.isNotEmpty) {
      total = normalizedRequests.values.fold(0, (sum, val) => sum + val);
    }

    return AdminStats(
      totalPatients: json['totalPatients'] ?? 0,
      totalProfessionals: json['totalProfessionals'] ?? 0,
      pendingValidations: json['pendingValidations'] ?? 0,
      totalSosRequests: total,
      completedMissions: json['completedMissions'] ?? 0,
      requestsByService: normalizedRequests,
      professionalsByStatus: Map<String, int>.from(json['professionalsByStatus'] ?? {}),
    );
  }

  factory AdminStats.empty() => AdminStats(
    totalPatients: 0,
    totalProfessionals: 0,
    pendingValidations: 0,
    totalSosRequests: 0,
    completedMissions: 0,
    requestsByService: {},
    professionalsByStatus: {},
  );
}
