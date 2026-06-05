package ma.skylark.msd.domain.entity;

import lombok.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;
import jakarta.persistence.*;

/**
 * Represents a medication treatment plan for a specific user.
 */
@Entity
@Getter @Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@SuppressWarnings("unused")
public class Medication {
    @Id
    private UUID id;

    @Column(nullable = false)
    private String userId; // Identity Subject from Keycloak

    @Column(nullable = false)
    private String medicationName;

    private String dosage;
    private String instructions;

    @Column(nullable = false)
    private LocalDate startDate;

    @Column(nullable = false)
    private Integer durationInDays;

    private Integer initialStock;
    private Integer currentStock;
    private Integer lowStockThreshold;

    @ElementCollection(fetch = FetchType.LAZY)
    @CollectionTable(name = "medication_intake_times", joinColumns = @JoinColumn(name = "medication_id"))
    @Column(name = "intake_time")
    private List<LocalTime> intakeTimes;

    private String reminderType; 
    private Integer leadTimeMinutes;
    private Integer snoozeIntervalMinutes;
}