package ma.skylark.msd.controller.dto;

import ma.skylark.msd.domain.model.ValidationStatus;
import java.util.List;

public record ProfessionalReviewResponse(
    Long professionalInfoId,
    String firstName,
    String lastName,
    String email,
    String serviceType,
    String specialty,
    String ambulanceType,
    ValidationStatus status,
    List<ProfessionalDocumentResponse> documents
) {}
