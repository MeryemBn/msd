package ma.skylark.msd.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.skylark.msd.controller.dto.CreateSosRequest;
import ma.skylark.msd.controller.dto.SosRequestResponse;
import ma.skylark.msd.controller.dto.UpdateSosStatusRequest;
import ma.skylark.msd.service.SosRequestService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

/**
 * Controller handling SOS request operations for authenticated patients.
 */
@RestController
@RequestMapping("/api/sos-requests")
@RequiredArgsConstructor
public class SosRequestController {

    private final SosRequestService sosRequestService;

    /**
     * Creates a new SOS request for the authenticated patient.
     */
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public SosRequestResponse create(@Valid @RequestBody CreateSosRequest request, @AuthenticationPrincipal Jwt jwt) {
        return sosRequestService.createRequest(request, jwt.getSubject());
    }

    /**
     * Retrieves all SOS requests.
     */
    @GetMapping
    public List<SosRequestResponse> getAll(@AuthenticationPrincipal Jwt jwt) {
        return sosRequestService.getMyRequests(jwt.getSubject());
    }

    /**
     * Updates the status of an SOS request (e.g. cancel).
     * Only the patient who created it can update the status.
     */
    @PatchMapping("/{id}/status")
    public SosRequestResponse updateStatus(@PathVariable UUID id,
            @Valid @RequestBody UpdateSosStatusRequest request,
            @AuthenticationPrincipal Jwt jwt) {
        return sosRequestService.updateStatus(id, request.status(), jwt.getSubject());
    }
}
