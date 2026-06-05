package ma.skylark.msd.controller.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * Request DTO carrying SOS intervention location details.
 */
public record LocationDetailsRequest(
        @NotBlank @Size(max = 255) String address,
        @Size(max = 50) String apartment,
        @Size(max = 50) String floor,
        @Size(max = 50) String entryCode,
        @NotNull @Min(-90) @Max(90) Double latitude,
        @NotNull @Min(-180) @Max(180) Double longitude
) {
}
