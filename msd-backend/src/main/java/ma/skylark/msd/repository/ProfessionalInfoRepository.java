package ma.skylark.msd.repository;

import ma.skylark.msd.domain.entity.ProfessionalInfo;
import ma.skylark.msd.domain.model.ValidationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProfessionalInfoRepository extends JpaRepository<ProfessionalInfo, Long> {
    Optional<ProfessionalInfo> findByUserId(Long userId);

    long countByStatusValidation(ValidationStatus status);

    @Modifying
    @Query("UPDATE ProfessionalInfo p SET p.completedMissionsCount = COALESCE(p.completedMissionsCount, 0) + 1 WHERE p.user.id = :userId")
    void incrementCompletedMissionsCount(@Param("userId") Long userId);

    @Query("""
        SELECT p FROM ProfessionalInfo p
        WHERE p.isAvailable = true
        AND p.statusValidation = 'VALIDATED'
        AND (
            (LOWER(CAST(:serviceType AS text)) = 'nurse' AND LOWER(p.serviceType) = 'nurse')
            OR (LOWER(CAST(:serviceType AS text)) = 'ambulance' AND LOWER(p.serviceType) = 'ambulance' 
                AND (CAST(:ambulanceType AS text) IS NULL OR LOWER(p.ambulanceType) LIKE CONCAT('%', LOWER(CAST(:ambulanceType AS text)), '%')))
            OR (LOWER(CAST(:serviceType AS text)) = 'doctor' AND LOWER(p.serviceType) = 'doctor'
                AND (CAST(:specialty AS text) IS NULL OR LOWER(p.specialty) = LOWER(CAST(:specialty AS text))))
            OR (LOWER(CAST(:serviceType AS text)) = 'teleconsultation' AND LOWER(p.serviceType) = 'doctor'
                AND (CAST(:specialty AS text) IS NULL OR LOWER(p.specialty) = LOWER(CAST(:specialty AS text))))
        )
    """)
    List<ProfessionalInfo> findEligibleProfessionals(
            @Param("serviceType") String serviceType,
            @Param("specialty") String specialty,
            @Param("ambulanceType") String ambulanceType);

    List<ProfessionalInfo> findByServiceTypeAndIsAvailableTrue(String serviceType);
    List<ProfessionalInfo> findByServiceTypeAndSpecialtyAndIsAvailableTrue(String serviceType, String specialty);
    List<ProfessionalInfo> findByServiceTypeAndAmbulanceTypeAndIsAvailableTrue(String serviceType, String ambulanceType);
    List<ProfessionalInfo> findByIsAvailableTrue();
}
