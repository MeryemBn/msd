package ma.skylark.msd.integration.keycloak.exception;

/**
 * Thrown when communication with Keycloak fails unexpectedly.
 * This covers network errors, timeouts, and unexpected response codes.
 */
public class KeycloakCommunicationException extends RuntimeException {

    public KeycloakCommunicationException(String message) {
        super(message);
    }

    public KeycloakCommunicationException(String message, Throwable cause) {
        super(message, cause);
    }
}
