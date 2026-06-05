package ma.skylark.msd.exception;

import java.time.Instant;

/**
 * Standard error response envelope for all API errors.
 * Provides a consistent shape for clients to parse.
 */
public record ErrorResponse(
        int status,
        String error,
        String message,
        Instant timestamp) {

    public static ErrorResponse of(int status, String error, String message) {
        return new ErrorResponse(status, error, message, Instant.now());
    }
}
