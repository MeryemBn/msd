package ma.skylark.msd.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import ma.skylark.msd.controller.dto.*;
import ma.skylark.msd.service.AuthService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

/**
 * Authentication endpoints wrapping Keycloak operations.
 * <p>
 * Public endpoints: signup, login, refresh.
 * Authenticated endpoints: change-password.
 */
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * Registers a new user.
     *
     * @param request the signup details
     * @return 201 Created on success
     * @throws ma.skylark.msd.domain.exception.UserAlreadyExistsException →
     *                                                                           409
     */
    @PostMapping("/signup")
    public ResponseEntity<Void> signup(@Valid @RequestBody SignupRequest request) {
        authService.signup(request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }

    /**
     * Authenticates a user and returns tokens.
     *
     * @param request the login credentials
     * @return 200 with access and refresh tokens
     * @throws ma.skylark.msd.domain.exception.InvalidCredentialsException →
     *                                                                            401
     */
    @PostMapping("/login")
    public ResponseEntity<TokenResponse> login(@Valid @RequestBody LoginRequest request) {
        var tokenResponse = authService.login(request);
        return ResponseEntity.ok(tokenResponse);
    }

    /**
     * Exchanges a refresh token for a new access token.
     *
     * @param request the refresh token
     * @return 200 with new tokens
     * @throws ma.skylark.msd.domain.exception.TokenRefreshException → 401
     */
    @PostMapping("/refresh")
    public ResponseEntity<TokenResponse> refresh(@Valid @RequestBody RefreshRequest request) {
        var tokenResponse = authService.refreshToken(request);
        return ResponseEntity.ok(tokenResponse);
    }

    /**
     * Changes the authenticated user's password.
     * Requires a valid JWT — the user ID is extracted from the token subject.
     *
     * @param jwt     the authenticated user's JWT
     * @param request the new password
     * @return 204 No Content on success
     */
    @PostMapping("/change-password")
    public ResponseEntity<Void> changePassword(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody ChangePasswordRequest request) {
        authService.changePassword(jwt.getSubject(), request);
        return ResponseEntity.noContent().build();
    }


    @PostMapping("/forgot-password")
    public ResponseEntity<Void> forgotPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        if (email == null || email.isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        authService.forgotPassword(email);
        return ResponseEntity.ok().build();
    }
}
