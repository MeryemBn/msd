package ma.skylark.msd.integration.keycloak.dto;

/**
 * Represents the token response from Keycloak's token endpoint.
 * Maps the OAuth2 token response fields.
 */
public record KeycloakTokenResponse(
        String access_token,
        String refresh_token,
        int expires_in,
        int refresh_expires_in,
        String token_type) {
}
