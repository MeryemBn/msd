package ma.skylark.msd.controller.dto;

import jakarta.validation.constraints.NotNull;
import ma.skylark.msd.domain.model.RequestStatus;

/**
 * Request body for updating the status of an SOS request.
 */
public record UpdateSosStatusRequest(
        @NotNull RequestStatus status
) {
}
