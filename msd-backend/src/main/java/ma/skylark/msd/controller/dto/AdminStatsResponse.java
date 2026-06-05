package ma.skylark.msd.controller.dto;

import java.util.Map;

public record AdminStatsResponse(
    long totalPatients,
    long totalProfessionals,
    long pendingValidations,
    long totalSosRequests,
    long completedMissions,
    Map<String, Long> requestsByService,
    Map<String, Long> professionalsByStatus
) {}
