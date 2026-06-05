package ma.skylark.msd.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

/**
 * Represents a single medical record entry for a patient.
 * Examples: allergy, chronic disease, surgery, medication.
 * A patient can have multiple records.
 */
@Entity
@Table(name = "patient_medical_records")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PatientMedicalRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "patient_id", nullable = false)
    private Long patientId;

    @Column(name = "type", nullable = false, columnDefinition = "TEXT")
    private String type;

    @Column(name = "description", nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(name = "severity", length = 50)
    private String severity;

    @Column(name = "diagnosed_at")
    private LocalDate diagnosedAt;
}
