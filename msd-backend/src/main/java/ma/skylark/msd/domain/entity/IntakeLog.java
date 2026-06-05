package ma.skylark.msd.domain.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.*;
import ma.skylark.msd.domain.model.IntakeStatus;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

/**
 * Intake journal entry: calendar day, slot index, and {@link #slotTime} (user-customizable),
 * plus the user-reported taken time when status is {@code TAKEN}.
 */
@Entity
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IntakeLog {
    @Id
    private UUID id;

    /**
     * Calendar day this row belongs to (daily list / agenda filtering).
     */
    @Column(name = "intake_date", nullable = false)
    private LocalDate intakeDate;

    /**
     * Index into {@link Medication#getIntakeTimes()} for that day (0 = first daily slot, etc.).
     */
    @Column(name = "day_slot_index", nullable = false)
    private int daySlotIndex;

    /**
     * Display / reminder time for this slot (initialized from the treatment plan, customizable).
     */
    @Column(name = "slot_time", nullable = false)
    private LocalTime slotTime;

    /**
     * When the user reports having taken the dose (only when status is {@code TAKEN}).
     */
    @Column(name = "actual_taken_date_time")
    private LocalDateTime actualTakenDateTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private IntakeStatus status;

    // --- RELATION JPA ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "medication_id", nullable = false)
    @JsonIgnore // Avoid circular reference in JSON serialization
    private Medication medication;

    // --- Flutter / JSON helper ---
    /**
     * Helper method for Jackson to include the medication ID in the JSON response
     * without serializing the entire Medication entity.
     */
    @JsonProperty("treatmentId")
    public UUID getTreatmentId() {
        return medication != null ? medication.getId() : null;
    }
}
