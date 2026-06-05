package ma.skylark.msd.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.skylark.msd.controller.dto.*;
import ma.skylark.msd.domain.entity.ProfessionalInfo;
import ma.skylark.msd.domain.entity.UserProfile;
import ma.skylark.msd.domain.exception.InvalidCredentialsException;
import ma.skylark.msd.domain.exception.ProfileNotFoundException;
import ma.skylark.msd.domain.exception.TokenRefreshException;
import ma.skylark.msd.domain.exception.UserAlreadyExistsException;
import ma.skylark.msd.integration.keycloak.KeycloakAuthAdapter;
import ma.skylark.msd.integration.keycloak.exception.KeycloakCommunicationException;
import ma.skylark.msd.repository.ProfessionalInfoRepository;
import ma.skylark.msd.repository.UserProfileRepository;
import ma.skylark.msd.domain.model.ValidationStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final KeycloakAuthAdapter keycloakAuthAdapter;
    private final UserProfileService userProfileService;
    private final UserProfileRepository userProfileRepository;
    private final ProfessionalInfoRepository professionalInfoRepository;

    @Transactional
    public void signup(SignupRequest request) {
        try {
            var keycloakId = keycloakAuthAdapter.createUser(
                    request.username(),
                    request.email(),
                    request.firstName(),
                    request.lastName(),
                    request.password(),
                    request.role()
            );

            if (keycloakId != null) {
                userProfileService.createProfile(keycloakId, request.firstName(), request.lastName(), request.email());

                if ("professional".equalsIgnoreCase(request.role())) {
                    UserProfile userProfile = userProfileRepository.findByKeycloakId(keycloakId)
                            .orElseThrow(() -> new ProfileNotFoundException("Profile not found after creation"));

                    ProfessionalInfo proInfo = ProfessionalInfo.builder()
                            .user(userProfile)
                            .isAvailable(false)
                            .statusValidation(ValidationStatus.PENDING)
                            .build();

                    professionalInfoRepository.save(proInfo);
                    log.info("Professional info initialized for user '{}'", request.username());
                }
            }
        } catch (KeycloakCommunicationException e) {
            if (e.getMessage() != null && e.getMessage().contains("409")) {
                throw new UserAlreadyExistsException("User already exists");
            }
            throw e;
        }
    }

    public TokenResponse login(LoginRequest request) {
        try {
            var keycloakResponse = keycloakAuthAdapter.authenticate(request.username(), request.password());
            return TokenResponse.from(keycloakResponse);
        } catch (KeycloakCommunicationException e) {
            String errorDetail = e.getMessage() != null ? e.getMessage() : "";
            if (errorDetail.contains("Account is not fully set up")) {
                throw new InvalidCredentialsException("EMAIL_NOT_VERIFIED");
            }
            if (errorDetail.contains("401") || errorDetail.contains("400") || errorDetail.contains("invalid_grant")) {
                throw new InvalidCredentialsException("INVALID_CREDENTIALS");
            }
            throw e;
        }
    }

    public TokenResponse refreshToken(RefreshRequest request) {
        try {
            var keycloakResponse = keycloakAuthAdapter.refreshToken(request.refreshToken());
            return TokenResponse.from(keycloakResponse);
        } catch (KeycloakCommunicationException e) {
            if (e.getMessage() != null && e.getMessage().contains("400")) {
                throw new TokenRefreshException("Refresh token is invalid or expired");
            }
            throw e;
        }
    }

    public void changePassword(String userId, ChangePasswordRequest request) {
        keycloakAuthAdapter.changePassword(userId, request.newPassword());
    }

    public void forgotPassword(String email) {
        keycloakAuthAdapter.sendForgotPasswordEmail(email);
    }
}
