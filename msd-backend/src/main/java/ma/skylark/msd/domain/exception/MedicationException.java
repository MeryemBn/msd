package ma.skylark.msd.domain.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

/**
 * Base exception for all medication-related business errors.
 */
@ResponseStatus(HttpStatus.BAD_REQUEST)
public class MedicationException extends RuntimeException {
    public MedicationException(String message) {
        super(message);
    }
}

/**
 * Thrown when an operation is attempted on a medication that doesn't exist.
 */
class ResourceNotFoundException extends MedicationException {
    public ResourceNotFoundException(String resource, String id) {
        super(String.format("%s with ID %s not found", resource, id));
    }
}

/**
 * Thrown when trying to take a medication but the stock is empty.
 */
class InsufficientStockException extends MedicationException {
    public InsufficientStockException(String medicationName) {
        super("Insufficient stock for medication: " + medicationName);
    }
}