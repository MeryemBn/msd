package ma.skylark.msd.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.skylark.msd.controller.dto.IntakeResponse;
import ma.skylark.msd.controller.dto.IntakeStatusUpdateRequest;
import ma.skylark.msd.controller.dto.MedicationRequest;
import ma.skylark.msd.controller.dto.MedicationResponse;
import ma.skylark.msd.controller.dto.MedicationStockUpdateRequest;
import ma.skylark.msd.domain.exception.MedicationException;
import ma.skylark.msd.domain.model.IntakeStatus;
import ma.skylark.msd.service.MedicationService;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/**
 * Controller handling medication and intake tracking operations.
 */
@RestController
@RequestMapping("/api/medications")
@RequiredArgsConstructor
public class MedicationController {

    private final MedicationService medicationService;

    /**
     * Retrieves all medications belonging to the authenticated user.
     */
    @GetMapping
    public List<MedicationResponse> getMyMedications(@AuthenticationPrincipal Jwt jwt) {
        return medicationService.getMyMedications(jwt.getSubject());
    }

        /**
     * Retrieves scheduled intakes for a specific date or a date range.
     *
     * @param date    target date (or start date) in ISO format (YYYY-MM-DD)
     * @param endDate optional end date in ISO format (YYYY-MM-DD)
     */
    @GetMapping("/intakes")
    public List<IntakeResponse> getIntakes(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            @AuthenticationPrincipal Jwt jwt) {
        if (endDate != null) {
            return medicationService.getIntakesForRange(jwt.getSubject(), date, endDate);
        }
        return medicationService.getDailyIntakes(jwt.getSubject(), date);
    }
    /**
     * Creates a new medication plan and generates its intake schedule.
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public MedicationResponse add(@Valid @RequestBody MedicationRequest req, @AuthenticationPrincipal Jwt jwt) {
        return medicationService.createMedication(req, jwt.getSubject());
    }

    /**
     * Updates an intake log: {@code status} and/or {@code slotTime}, with optional
     * {@code actualTakenDateTime} when marking {@code TAKEN}. At least one of {@code status} or
     * {@code slotTime} must be present in the body.
     *
     * @param id   intake log identifier
     * @param body {@link IntakeStatusUpdateRequest} — {@code status}, {@code slotTime} (ISO time string), {@code actualTakenDateTime}
     */
    @PatchMapping("/intakes/{id}")
    public void updateStatus(@PathVariable UUID id, @RequestBody IntakeStatusUpdateRequest body) {
        boolean hasStatus = body.status() != null && !body.status().isBlank();
        if (!hasStatus && body.slotTime() == null) {
            throw new MedicationException("Either status or slotTime is required");
        }
        IntakeStatus status = hasStatus
                ? IntakeStatus.valueOf(body.status().trim().toUpperCase())
                : null;
        medicationService.updateIntakeStatus(id, status, body.actualTakenDateTime(), body.slotTime());
    }

        /**
     * Updates the current stock for a specific medication.
     */
    @PatchMapping("/{id}")
    public MedicationResponse updateStock(
            @PathVariable UUID id,
            @RequestBody MedicationStockUpdateRequest req,
            @AuthenticationPrincipal Jwt jwt) {
        return medicationService.updateStock(id, req.currentStock(), jwt.getSubject());
    }
}
