package ma.skylark.msd.repository;

import ma.skylark.msd.domain.entity.ProfessionalPricing;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProfessionalPricingRepository extends JpaRepository<ProfessionalPricing, Long> {
    List<ProfessionalPricing> findByProfessionalId(Long professionalId);
    
    @Query("""
        SELECT p FROM ProfessionalPricing p 
        WHERE p.professionalId = :proId 
        AND UPPER(p.serviceType) = UPPER(:serviceType) 
        AND (
            (:specialty IS NULL OR :specialty = '' OR UPPER(p.specialty) = UPPER(:specialty))
            OR (p.specialty IS NULL)
        )
        AND (
            (:ambulanceType IS NULL OR :ambulanceType = '' OR UPPER(p.ambulanceType) = UPPER(:ambulanceType))
            OR (p.ambulanceType IS NULL)
        )
        AND UPPER(p.interventionMode) = UPPER(:mode)
        AND p.isActive = true
        ORDER BY p.specialty DESC, p.ambulanceType DESC
    """)
    List<ProfessionalPricing> findPricingCandidates(
            @Param("proId") Long proId, 
            @Param("serviceType") String serviceType, 
            @Param("specialty") String specialty, 
            @Param("ambulanceType") String ambulanceType, 
            @Param("mode") String mode);

    default Optional<ProfessionalPricing> findPricingCustom(Long proId, String serviceType, String specialty, String ambulanceType, String mode) {
        List<ProfessionalPricing> candidates = findPricingCandidates(proId, serviceType, specialty, ambulanceType, mode);
        return candidates.isEmpty() ? Optional.empty() : Optional.of(candidates.get(0));
    }

    @Query("""
        SELECT AVG(p.price) 
        FROM ProfessionalPricing p 
        JOIN ProfessionalInfo pi ON p.professionalId = pi.user.id
        WHERE UPPER(p.serviceType) = UPPER(:serviceType) 
        AND (
            (:specialty IS NULL OR :specialty = '' OR UPPER(p.specialty) = UPPER(:specialty))
            OR (p.specialty IS NULL)
        )
        AND (
            (:ambulanceType IS NULL OR :ambulanceType = '' OR UPPER(p.ambulanceType) = UPPER(:ambulanceType))
            OR (p.ambulanceType IS NULL)
        )
        AND UPPER(p.interventionMode) = UPPER(:mode)
        AND p.isActive = true
        AND pi.isAvailable = true
        AND pi.statusValidation = ma.skylark.msd.domain.model.ValidationStatus.VALIDATED
    """)
    BigDecimal getAvgPriceForService(
            @Param("serviceType") String serviceType, 
            @Param("specialty") String specialty, 
            @Param("ambulanceType") String ambulanceType, 
            @Param("mode") String mode);
}
