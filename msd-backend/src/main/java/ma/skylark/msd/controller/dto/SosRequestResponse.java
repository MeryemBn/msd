package ma.skylark.msd.controller.dto;

import ma.skylark.msd.domain.entity.SosRequest;
import ma.skylark.msd.domain.entity.UserProfile;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Response DTO for SOS request details.
 * Includes patient and professional basic info for display purposes.
 */
public record SosRequestResponse(
        UUID id,
        Long patientId,
        String patientFirstName,
        String patientLastName,
        String patientPhoneNumber,
        Long professionalId,
        String professionalFirstName,
        String professionalLastName,
        String professionalPhoneNumber,
        String serviceType,
        String interventionMode,
        String status,
        BigDecimal price,
        String paymentMethod,
        LocalDateTime appointmentDatetime,
        String specialty,
        String ambulanceType,
        LocationDetailsResponse location,
        boolean isRated,
        Integer rating,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
    
    public static SosRequestResponse fromEntity(SosRequest entity) {
        return fromEntity(entity, null, null, false, null);
    }

    public static SosRequestResponse fromEntity(SosRequest entity, UserProfile patient, UserProfile professional) {
        return fromEntity(entity, patient, professional, false, null);
    }

    public static SosRequestResponse fromEntity(SosRequest entity, UserProfile patient, UserProfile professional, boolean isRated, Integer rating) {
        return new SosRequestResponse(
                entity.getId(),
                entity.getPatientId(),
                patient != null ? patient.getFirstName() : null,
                patient != null ? patient.getLastName() : null,
                patient != null ? patient.getPhoneNumber() : null,
                entity.getProfessionalId(),
                professional != null ? professional.getFirstName() : null,
                professional != null ? professional.getLastName() : null,
                professional != null ? professional.getPhoneNumber() : null,
                entity.getServiceType(),
                entity.getInterventionMode(),
                entity.getStatus(),
                entity.getPrice(),
                entity.getPaymentMethod(),
                entity.getAppointmentDatetime(),
                entity.getSpecialty(),
                entity.getAmbulanceType(),
                entity.getLocation() != null ? new LocationDetailsResponse(
                        entity.getLocation().getAddress(),
                        entity.getLocation().getApartment(),
                        entity.getLocation().getFloor(),
                        entity.getLocation().getEntryCode(),
                        entity.getLocation().getLatitude(),
                        entity.getLocation().getLongitude()
                ) : null,
                isRated,
                rating,
                entity.getCreatedAt(),
                entity.getUpdatedAt()
        );
    }
}
