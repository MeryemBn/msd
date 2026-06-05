package ma.skylark.msd.controller;

import lombok.RequiredArgsConstructor;
import ma.skylark.msd.controller.dto.AdminStatsResponse;
import ma.skylark.msd.controller.dto.ProfessionalReviewResponse;
import ma.skylark.msd.controller.dto.SosRequestResponse;
import ma.skylark.msd.controller.dto.UserProfileResponse;
import ma.skylark.msd.domain.model.ValidationStatus;
import ma.skylark.msd.service.AdminService;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controller for admin-only operations including professional validation and statistics.
 */
@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminService adminService;

    /**
     * Returns general statistics for the dashboard.
     */
    @GetMapping("/stats")
    public AdminStatsResponse getStats() {
        return adminService.getStats();
    }

    /**
     * Lists all professionals in the system.
     */
    @GetMapping("/professionals")
    public List<ProfessionalReviewResponse> getAllProfessionals() {
        return adminService.getAllProfessionals();
    }

    /**
     * Lists all patients in the system.
     */
    @GetMapping("/patients")
    public List<UserProfileResponse> getAllPatients() {
        return adminService.getAllPatients();
    }

    /**
     * Lists all SOS requests in the system.
     */
    @GetMapping("/requests")
    public List<SosRequestResponse> getAllRequests() {
        return adminService.getAllRequests();
    }

    /**
     * Lists all professionals with a specific validation status.
     */
    @GetMapping("/pending-professionals")
    public List<ProfessionalReviewResponse> getPendingProfessionals() {
        return adminService.getProfessionalsByStatus(ValidationStatus.PENDING);
    }

    /**
     * Returns full details for a professional's validation including documents.
     */
    @GetMapping("/professionals/{id}")
    public ProfessionalReviewResponse getProfessionalDetails(@PathVariable Long id) {
        return adminService.getProfessionalDetails(id);
    }

    /**
     * Validates a professional's profile.
     */
    @PostMapping("/professionals/{id}/validate")
    public void validateProfessional(@PathVariable Long id) {
        adminService.updateProfessionalStatus(id, ValidationStatus.VALIDATED, null);
    }

    /**
     * Rejects a professional's profile with a specific reason.
     */
    @PostMapping("/professionals/{id}/reject")
    public void rejectProfessional(@PathVariable Long id, @RequestBody String reason) {
        adminService.updateProfessionalStatus(id, ValidationStatus.REJECTED, reason);
    }
}
