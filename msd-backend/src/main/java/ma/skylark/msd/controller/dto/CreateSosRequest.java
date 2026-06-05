package ma.skylark.msd.controller.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import ma.skylark.msd.domain.model.AmbulanceType;
import ma.skylark.msd.domain.model.InterventionMode;
import ma.skylark.msd.domain.model.PaymentMethod;
import ma.skylark.msd.domain.model.ServiceType;
import ma.skylark.msd.domain.model.Specialty;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Request DTO for creating a new SOS request.
 */
public record CreateSosRequest(
        @NotNull ServiceType serviceType,
        AmbulanceType ambulanceType,
        Specialty specialty,
        @NotNull InterventionMode interventionMode,
        LocalDateTime appointmentDatetime,
        @NotNull PaymentMethod paymentMethod,
        @DecimalMin(value = "0.0", inclusive = true) BigDecimal price,
        @Valid LocationDetailsRequest location,
        Long professionalId
) {
}
