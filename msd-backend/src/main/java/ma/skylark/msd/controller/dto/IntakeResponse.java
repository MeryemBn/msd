package ma.skylark.msd.controller.dto;

import ma.skylark.msd.domain.entity.IntakeLog;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.UUID;

/**
 * Data Transfer Object for medication intake logs.
 */
public record IntakeResponse(
        UUID id,
        UUID treatmentId,
        LocalDate intakeDate,
        LocalTime slotTime,
        LocalDateTime actualTakenDateTime,
        String status
) {
    public static IntakeResponse fromEntity(IntakeLog log) {
        return new IntakeResponse(
                log.getId(),
                log.getMedication().getId(),
                log.getIntakeDate(),
                log.getSlotTime(),
                log.getActualTakenDateTime(),
                log.getStatus().name()
        );
    }
}
