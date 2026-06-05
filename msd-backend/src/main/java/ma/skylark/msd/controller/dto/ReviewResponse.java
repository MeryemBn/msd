package ma.skylark.msd.controller.dto;

import java.time.LocalDateTime;

public record ReviewResponse(
    Long id,
    String patientFirstName,
    String patientLastName,
    Integer rating,
    String comment,
    LocalDateTime createdAt
) {}
