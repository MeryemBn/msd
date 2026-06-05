package ma.skylark.msd.controller.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record CreateReviewRequest(
        @NotNull(message = "L'ID de la demande est obligatoire")
        UUID sosRequestId,

        @NotNull(message = "La note est obligatoire")
        @Min(value = 1, message = "La note minimale est 1")
        @Max(value = 5, message = "La note maximale est 5")
        Integer rating,

        String comment
) {}
