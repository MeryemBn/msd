package ma.skylark.msd.repository;

import ma.skylark.msd.domain.entity.SosRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface SosRequestRepository extends JpaRepository<SosRequest, UUID> {

    List<SosRequest> findByPatientId(Long patientId);

    @Query("""
        SELECT s FROM SosRequest s 
        LEFT JOIN FETCH s.location
        WHERE LOWER(s.status) = 'pending' 
        AND s.professionalId IS NULL 
        AND LOWER(s.serviceType) = LOWER(:serviceType) 
        AND (
            LOWER(:serviceType) = 'nurse' 
            OR (LOWER(:serviceType) = 'ambulance' 
                AND (s.ambulanceType IS NULL 
                     OR LOWER(:specialty) LIKE CONCAT('%', LOWER(s.ambulanceType), '%')))
            OR (LOWER(:serviceType) = 'doctor' 
                AND (s.specialty IS NULL OR LOWER(s.specialty) = LOWER(:specialty)))
            OR (LOWER(:serviceType) = 'teleconsultation' 
                AND (s.specialty IS NULL OR LOWER(s.specialty) = LOWER(:specialty)))
            OR (:specialty IS NULL)
        )
        ORDER BY s.createdAt DESC
    """)
    List<SosRequest> findAvailableRequests(
            @Param("serviceType") String serviceType,
            @Param("specialty") String specialty);

    @Query("""
        SELECT s FROM SosRequest s 
        LEFT JOIN FETCH s.location
        WHERE s.professionalId = :proId 
        AND (LOWER(s.status) = 'on_the_way' 
             OR LOWER(s.status) = 'in_progress')
    """)
    Optional<SosRequest> findActiveMissionByProfessional(@Param("proId") Long proId);

    @Query("""
        SELECT s FROM SosRequest s 
        LEFT JOIN FETCH s.location
        WHERE s.professionalId = :proId 
        AND LOWER(s.status) IN ('confirmed', 'on_the_way', 'in_progress', 'awaiting_payment')
        ORDER BY s.createdAt DESC
    """)
    List<SosRequest> findAllActiveMissionsByProfessional(@Param("proId") Long proId);

    List<SosRequest> findByProfessionalId(Long professionalId);

    List<SosRequest> findByProfessionalIdAndStatusIgnoreCase(Long professionalId, String status);

    @Query("""
        SELECT COUNT(s) > 0 FROM SosRequest s
        WHERE s.professionalId = :professionalId
        AND s.appointmentDatetime = :appointmentDatetime
        AND LOWER(s.status) NOT IN ('cancelled', 'rejected', 'completed')
    """)
    boolean existsByProfessionalIdAndAppointmentDatetime(
            @Param("professionalId") Long professionalId,
            @Param("appointmentDatetime") java.time.LocalDateTime appointmentDatetime);

    @Query("""
        SELECT s.appointmentDatetime FROM SosRequest s
        WHERE s.professionalId = :professionalId
        AND s.appointmentDatetime >= :startOfDay
        AND s.appointmentDatetime < :endOfDay
        AND LOWER(s.status) NOT IN ('cancelled', 'rejected', 'completed')
    """)
    List<java.time.LocalDateTime> findBookedTimesByProfessionalAndDate(
            @Param("professionalId") Long professionalId,
            @Param("startOfDay") java.time.LocalDateTime startOfDay,
            @Param("endOfDay") java.time.LocalDateTime endOfDay);

    @Query("""
        SELECT COUNT(s) > 0 FROM SosRequest s
        WHERE s.patientId = :patientId
        AND s.professionalId = :professionalId
        AND LOWER(s.interventionMode) = 'appointment'
        AND LOWER(s.status) IN ('pending', 'confirmed', 'on_the_way', 'in_progress', 'awaiting_payment')
    """)
    boolean existsOngoingAppointmentByPatientAndProfessional(
            @Param("patientId") Long patientId,
            @Param("professionalId") Long professionalId);

    @Query("""
        SELECT COALESCE(SUM(s.price), 0) FROM SosRequest s
        WHERE s.professionalId = :professionalId
        AND LOWER(s.status) = 'completed'
    """)
    BigDecimal calculateTotalRevenue(@Param("professionalId") Long professionalId);

    @Query("""
        SELECT s FROM SosRequest s
        WHERE s.professionalId = :professionalId
        AND LOWER(s.status) = 'completed'
        ORDER BY s.createdAt DESC
    """)
    List<SosRequest> findCompletedMissionsByProfessional(@Param("professionalId") Long professionalId);
}
