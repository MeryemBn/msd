package ma.skylark.msd.controller;

import ma.skylark.msd.controller.dto.UpdateProfileRequest;
import ma.skylark.msd.controller.dto.UserProfileResponse;
import ma.skylark.msd.domain.entity.PatientMedicalRecord;
import ma.skylark.msd.service.UserProfileService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

/**
 * Profile endpoints for the currently authenticated user.
 * User identity is derived from the JWT subject claim.
 */
@RestController
@RequestMapping("/api/profiles")
@RequiredArgsConstructor
public class UserProfileController {

    private final UserProfileService userProfileService;

    /**
     * Returns the current user's profile.
     *
     * @param jwt the authenticated JWT
     * @return 200 with the profile data including medical records
     */
    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> getMyProfile(@AuthenticationPrincipal Jwt jwt) {
        var response = userProfileService.getProfile(jwt.getSubject());
        return ResponseEntity.ok(response);
    }

    /**
     * Updates the current user's profile.
     *
     * @param jwt     the authenticated JWT
     * @param request the updated profile data
     * @return 200 with the updated profile
     */
    @PutMapping("/me")
    public ResponseEntity<UserProfileResponse> updateMyProfile(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody UpdateProfileRequest request) {
        var response = userProfileService.updateProfile(jwt.getSubject(), request);
        return ResponseEntity.ok(response);
    }

    /**
     * Marks the current user's profile as complete.
     */
    @PutMapping("/me/complete")
    public ResponseEntity<Void> markProfileAsComplete(@AuthenticationPrincipal Jwt jwt) {
        userProfileService.markProfileAsComplete(jwt.getSubject());
        return ResponseEntity.ok().build();
    }

    /**
     * Uploads a professional document with OCR result.
     */
    @PostMapping("/me/documents")
    public ResponseEntity<Void> uploadDocument(
            @AuthenticationPrincipal Jwt jwt,
            @RequestParam("type") String type,
            @RequestParam(value = "ocrResult", required = false) String ocrResult,
            @RequestParam("file") MultipartFile file) throws IOException {
        userProfileService.uploadProfessionalDocument(jwt.getSubject(), type, ocrResult, file);
        return ResponseEntity.ok().build();
    }

    /**
     * Adds a medical record (allergy, history, etc.) to the user's profile.
     */
    @PostMapping("/me/medical-records")
    public ResponseEntity<PatientMedicalRecord> addMedicalRecord(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody PatientMedicalRecord record) {
        return ResponseEntity.ok(userProfileService.addMedicalRecord(jwt.getSubject(), record));
    }

    /**
     * Deletes a specific medical record from the user's profile.
     */
    @DeleteMapping("/me/medical-records/{id}")
    public ResponseEntity<Void> deleteMedicalRecord(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable Long id) {
        userProfileService.deleteMedicalRecord(jwt.getSubject(), id);
        return ResponseEntity.noContent().build();
    }
}
