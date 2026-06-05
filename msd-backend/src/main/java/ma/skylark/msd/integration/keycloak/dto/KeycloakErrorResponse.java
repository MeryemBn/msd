package ma.skylark.msd.integration.keycloak.dto;

/**
 * Represents the error response from Keycloak's token endpoint.
 */
public record KeycloakErrorResponse(
        String error,
        String error_description) {
}
