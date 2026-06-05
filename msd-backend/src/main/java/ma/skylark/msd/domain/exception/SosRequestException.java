package ma.skylark.msd.domain.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Thrown when an SOS request operation violates a business rule.
 */
@ResponseStatus(HttpStatus.BAD_REQUEST)
public class SosRequestException extends RuntimeException {
    public SosRequestException(String message) {
        super(message);
    }
}
