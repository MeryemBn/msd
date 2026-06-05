package ma.skylark.msd.controller.dto;

import ma.skylark.msd.integration.keycloak.dto.KeycloakTokenResponse;

/**
 * API response DTO for token operations (login, refresh).
 * Maps from the internal Keycloak token response to a clean API shape.
 */
public record TokenResponse(
        String accessToken,
        String refreshToken,
        int expiresIn,
        int refreshExpiresIn,
        String tokenType) {

    /**
     * Maps a Keycloak token response to the API response shape.
     */
    public static TokenResponse from(KeycloakTokenResponse keycloakResponse) {
        return new TokenResponse(
                keycloakResponse.access_token(),
                keycloakResponse.refresh_token(),
                keycloakResponse.expires_in(),
                keycloakResponse.refresh_expires_in(),
                keycloakResponse.token_type());
    }
}
