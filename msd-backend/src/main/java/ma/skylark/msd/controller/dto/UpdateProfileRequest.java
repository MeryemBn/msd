package ma.skylark.msd.controller.dto;

import jakarta.validation.constraints.Size;

/**
 * Request DTO for creating or updating a user profile.
 */
public record UpdateProfileRequest(
        @Size(max = 100) String firstName,
        @Size(max = 100) String lastName,
        @Size(max = 20) String phoneNumber,
        @Size(max = 500) String address,
        @Size(max = 100) String city,
        @Size(max = 100) String serviceType,
        @Size(max = 100) String specialty,
        @Size(max = 255) String ambulanceType) {
}
