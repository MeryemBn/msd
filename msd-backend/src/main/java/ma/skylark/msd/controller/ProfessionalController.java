package ma.skylark.msd.controller;

import lombok.RequiredArgsConstructor;
import ma.skylark.msd.controller.dto.ProfessionalStatusResponse;
import ma.skylark.msd.controller.dto.SosRequestResponse;
import ma.skylark.msd.controller.dto.UserProfileResponse;
import ma.skylark.msd.domain.model.RequestStatus;
import ma.skylark.msd.service.ProfessionalService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/professional")
@RequiredArgsConstructor
public class ProfessionalController {

    private final ProfessionalService professionalService;

    @GetMapping("/status")
    public ProfessionalStatusResponse getMyStatus(@AuthenticationPrincipal Jwt jwt) {
        return professionalService.getProfessionalStatus(jwt.getSubject());
    }

    @PatchMapping("/availability")
    public void toggleAvailability(@RequestParam boolean available, @AuthenticationPrincipal Jwt jwt) {
        professionalService.updateAvailability(jwt.getSubject(), available);
    }

    @PatchMapping("/location")
    public void updateLocation(
            @RequestParam Double latitude, 
            @RequestParam Double longitude, 
            @AuthenticationPrincipal Jwt jwt) {
        professionalService.updateLocation(jwt.getSubject(), latitude, longitude);
    }

    @GetMapping("/eligible-requests")
    public List<SosRequestResponse> getEligibleRequests(@AuthenticationPrincipal Jwt jwt) {
        return professionalService.getEligibleRequests(jwt.getSubject());
    }

    @GetMapping("/active-mission")
    public ResponseEntity<SosRequestResponse> getActiveMission(@AuthenticationPrincipal Jwt jwt) {
        return professionalService.getActiveMission(jwt.getSubject())
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.noContent().build());
    }

    @GetMapping("/missions")
    public List<SosRequestResponse> getMissions(@AuthenticationPrincipal Jwt jwt) {
        return professionalService.getMissions(jwt.getSubject());
    }

    @GetMapping("/pending-appointments")
    public List<SosRequestResponse> getPendingAppointments(@AuthenticationPrincipal Jwt jwt) {
        return professionalService.getPendingAppointments(jwt.getSubject());
    }

    @PostMapping("/requests/{id}/accept")
    public SosRequestResponse acceptRequest(@PathVariable UUID id, @AuthenticationPrincipal Jwt jwt) {
        return professionalService.acceptRequest(id, jwt.getSubject());
    }

    @PostMapping("/requests/{id}/reject")
    public SosRequestResponse rejectRequest(@PathVariable UUID id, @AuthenticationPrincipal Jwt jwt) {
        return professionalService.rejectRequest(id, jwt.getSubject());
    }

    @PatchMapping("/requests/{id}/status")
    public SosRequestResponse updateStatus(
            @PathVariable UUID id, 
            @RequestParam RequestStatus status, 
            @AuthenticationPrincipal Jwt jwt) {
        return professionalService.updateRequestStatus(id, status, jwt.getSubject());
    }

    @GetMapping("/search")
    public List<UserProfileResponse> searchProfessionals(
            @RequestParam String serviceType,
            @RequestParam(required = false) String specialty,
            @RequestParam(required = false) String ambulanceType,
            @RequestParam(required = false) Double latitude,
            @RequestParam(required = false) Double longitude,
            @RequestParam(required = false) Double maxDistance) {
        return professionalService.searchProfessionals(serviceType, specialty, ambulanceType, latitude, longitude, maxDistance);
    }

    @GetMapping("/{professionalId}/available-slots")
    public List<java.time.LocalDateTime> getAvailableSlots(
            @PathVariable Long professionalId,
            @RequestParam String date) {
        return professionalService.getAvailableSlots(professionalId, date);
    }
}
