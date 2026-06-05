package ma.skylark.msd.controller.dto;

import ma.skylark.msd.domain.entity.Medication;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

/**
 * Data Transfer Object for sending medication data to the client.
 */
public record MedicationResponse(
    UUID id,
    String medicationName,
    String dosage,
    String instructions,
    LocalDate startDate,
    Integer durationInDays,
    Integer currentStock,
    Integer lowStockThreshold, 
    List<LocalTime> intakeTimes,
    boolean isStockLow,
    String reminderType,
    Integer leadTimeMinutes,
    Integer snoozeIntervalMinutes
) {
    public static MedicationResponse fromEntity(Medication med) {
        return new MedicationResponse(
            med.getId(),
            med.getMedicationName(),
            med.getDosage(),
            med.getInstructions(),
            med.getStartDate(),
            med.getDurationInDays(),
            med.getCurrentStock(),
            med.getLowStockThreshold(), 
            List.copyOf(med.getIntakeTimes()),
            med.getCurrentStock() <= med.getLowStockThreshold(),
            med.getReminderType(),
            med.getLeadTimeMinutes(),
            med.getSnoozeIntervalMinutes()
        );
    }
}