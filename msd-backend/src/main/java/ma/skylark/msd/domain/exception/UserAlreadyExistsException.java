package ma.skylark.msd.domain.exception;

/**
 * Thrown when a signup attempt uses a username or email that already exists in
 * Keycloak.
 */
public class UserAlreadyExistsException extends RuntimeException {

    public UserAlreadyExistsException(String message) {
        super(message);
    }
}
