package ma.skylark.msd.controller.dto;

import ma.skylark.msd.domain.model.ValidationStatus;

public record ProfessionalStatusResponse(
    ValidationStatus status,
    boolean isSetupComplete,
    boolean hasUploadedDocuments,
    String type,
    String specialty,
    boolean isAvailable,
    Double averageRating,
    Integer totalReviews,
    Integer completedMissionsCount
) {}
