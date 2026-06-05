package ma.skylark.msd.controller.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * Mise à jour d'une prise : au moins un de {@code status} ou {@code slotTime}.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record IntakeStatusUpdateRequest(
        @Schema(example = "TAKEN", description = "Optionnel si slotTime est fourni")
        String status,
        @Schema(type = "string", format = "time", example = "09:15:00")
        LocalTime slotTime,
        @Schema(example = "2026-04-12T08:45:00")
        LocalDateTime actualTakenDateTime
) {}
