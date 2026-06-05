package ma.skylark.msd.repository;

import ma.skylark.msd.domain.entity.PatientMedicalRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repository for managing {@link PatientMedicalRecord} entities.
 * Used to store medical information such as blood type, insurance, allergies, and history.
 */
@Repository
public interface PatientMedicalRecordRepository extends JpaRepository<PatientMedicalRecord, Long> {

    /**
     * Retrieves all medical records associated with a specific patient.
     *
     * @param patientId the technical ID of the user profile
     * @return a list of medical records (allergies, medical history, etc.)
     */
    List<PatientMedicalRecord> findByPatientId(Long patientId);

    /**
     * Optional: Retrieves medical records by type for a specific patient.
     * Useful if you want to fetch only allergies or only medical history.
     */
    List<PatientMedicalRecord> findByPatientIdAndType(Long patientId, String type);
}