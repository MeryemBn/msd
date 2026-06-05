package ma.skylark.msd.controller.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Request DTO for password change.
 */
public record ChangePasswordRequest(

        @NotBlank(message = "New password is required") @Size(min = 8, max = 128, message = "Password must be between 8 and 128 characters") String newPassword) {
}
