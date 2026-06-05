package ma.skylark.msd.domain.exception;

/**
 * Thrown when a token refresh attempt fails (expired or invalid refresh token).
 */
public class TokenRefreshException extends RuntimeException {

    public TokenRefreshException(String message) {
        super(message);
    }
}
