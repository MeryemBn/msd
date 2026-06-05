package ma.skylark.msd.domain.exception;

/**
 * Thrown when login fails due to invalid username or password.
 */
public class InvalidCredentialsException extends RuntimeException {

    public InvalidCredentialsException(String message) {
        super(message);
    }
}
