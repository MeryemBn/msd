package ma.skylark.msd.domain.model;

/**
 * Lifecycle statuses for an SOS request.
 */
public enum RequestStatus {
    PENDING,
    AWAITING_PAYMENT,
    CONFIRMED,
    ON_THE_WAY,
    IN_PROGRESS,
    COMPLETED,
    CANCELLED,
    REJECTED
}
