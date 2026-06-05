package ma.skylark.msd.domain.exception;

/**
 * Thrown when a user profile is not found for a given Keycloak ID.
 */
public class ProfileNotFoundException extends RuntimeException {

    public ProfileNotFoundException(String message) {
        super(message);
    }
}
