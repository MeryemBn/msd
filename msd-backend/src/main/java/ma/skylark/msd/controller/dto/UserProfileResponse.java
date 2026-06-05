package ma.skylark.msd.controller.dto;

import ma.skylark.msd.domain.entity.UserProfile;
import ma.skylark.msd.domain.entity.PatientMedicalRecord;
import ma.skylark.msd.domain.model.ValidationStatus;
import java.time.Instant;
import java.util.List;

/**
 * API response DTO for user profile data.
 * Updated to include role identification, profile completion status, professional validation and trust indicators.
 */
public record UserProfileResponse(
        Long id,
        String firstName,
        String lastName,
        String email,
        String phoneNumber,
        String address,
        String city,
        boolean isProfileComplete,
        String serviceType,
        String specialty,
        String ambulanceType,
        Double latitude,
        Double longitude,
        Double distance,
        boolean isProfessional,
        boolean isAvailable,
        ValidationStatus statusValidation,
        String rejectionReason,
        Double averageRating,
        Integer totalReviews,
        Integer completedMissionsCount,
        List<PatientMedicalRecord> medicalRecords, 
        Instant createdAt,
        Instant updatedAt) {

    public static UserProfileResponse from(UserProfile profile, List<PatientMedicalRecord> medicalRecords) {
        return from(profile, medicalRecords, null);
    }

    public static UserProfileResponse from(UserProfile profile, List<PatientMedicalRecord> medicalRecords, Double distance) {
        String serviceType = null;
        String specialty = null;
        String ambulanceType = null;
        Double latitude = null;
        Double longitude = null;
        boolean isProfessional = false;
        boolean isAvailable = false;
        ValidationStatus statusValidation = null;
        String rejectionReason = null;
        Double averageRating = 0.0;
        Integer totalReviews = 0;
        Integer completedMissionsCount = 0;

        if (profile.getProfessionalInfo() != null) {
            isProfessional = true;
            serviceType = profile.getProfessionalInfo().getServiceType();
            specialty = profile.getProfessionalInfo().getSpecialty();
            ambulanceType = profile.getProfessionalInfo().getAmbulanceType();
            isAvailable = Boolean.TRUE.equals(profile.getProfessionalInfo().getIsAvailable());
            statusValidation = profile.getProfessionalInfo().getStatusValidation();
            rejectionReason = profile.getProfessionalInfo().getRejectionReason();
            latitude = profile.getProfessionalInfo().getLatitude();
            longitude = profile.getProfessionalInfo().getLongitude();
            averageRating = profile.getProfessionalInfo().getAverageRating();
            totalReviews = profile.getProfessionalInfo().getTotalReviews();
            completedMissionsCount = profile.getProfessionalInfo().getCompletedMissionsCount();
        }

        return new UserProfileResponse(
                profile.getId(),
                profile.getFirstName(),
                profile.getLastName(),
                profile.getEmail(),
                profile.getPhoneNumber(),
                profile.getAddress(),
                profile.getCity(),
                profile.isProfileComplete(),
                serviceType,
                specialty,
                ambulanceType,
                latitude,
                longitude,
                distance,
                isProfessional,
                isAvailable,
                statusValidation,
                rejectionReason,
                averageRating,
                totalReviews,
                completedMissionsCount,
                medicalRecords, 
                profile.getCreatedAt(),
                profile.getUpdatedAt());
    }
}
