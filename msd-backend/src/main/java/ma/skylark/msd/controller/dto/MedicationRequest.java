package ma.skylark.msd.controller.dto;import jakarta.validation.constraints.*;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/**
 * Data Transfer Object for creating a new medication plan.
 * Uses Java Record for immutability.
 */
public record MedicationRequest(
    @NotBlank @Size(max = 255) String medicationName,
    @Size(max = 100) String dosage,
    String instructions,
    @NotNull LocalDate startDate,
    @NotNull @Min(1) Integer durationInDays,
    @NotEmpty List<LocalTime> intakeTimes,
    @NotNull @Min(0) Integer initialStock,
    @NotNull @Min(0) Integer lowStockThreshold,
    String reminderType,
    Integer leadTimeMinutes,
    Integer snoozeIntervalMinutes
) {}