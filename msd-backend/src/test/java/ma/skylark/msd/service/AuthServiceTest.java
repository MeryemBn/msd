package ma.skylark.msd.service;

import ma.skylark.msd.controller.dto.*;
import ma.skylark.msd.domain.exception.InvalidCredentialsException;
import ma.skylark.msd.domain.exception.TokenRefreshException;
import ma.skylark.msd.domain.exception.UserAlreadyExistsException;
import ma.skylark.msd.integration.keycloak.KeycloakAuthAdapter;
import ma.skylark.msd.integration.keycloak.dto.KeycloakTokenResponse;
import ma.skylark.msd.integration.keycloak.exception.KeycloakCommunicationException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private KeycloakAuthAdapter keycloakAuthAdapter;

    @Mock
    private UserProfileService userProfileService;

    @InjectMocks
    private AuthService authService;

    // --- signup ---

    @Test
    void shouldSignupSuccessfully() {
        var request = new SignupRequest("john", "john@example.com", "John", "Doe", "password123");
        when(keycloakAuthAdapter.createUser("john", "john@example.com", "John", "Doe", "password123"))
                .thenReturn("user-id-123");

        authService.signup(request);

        verify(keycloakAuthAdapter).createUser("john", "john@example.com", "John", "Doe", "password123");
        verify(userProfileService).createProfile("user-id-123", "John", "Doe", "john@example.com");
    }

    @Test
    void shouldThrowUserAlreadyExists_whenKeycloakReturns409() {
        var request = new SignupRequest("john", "john@example.com", "John", "Doe", "password123");
        when(keycloakAuthAdapter.createUser("john", "john@example.com", "John", "Doe", "password123"))
                .thenThrow(new KeycloakCommunicationException(
                        "Keycloak operation 'createUser' failed: 409 Conflict"));

        assertThatThrownBy(() -> authService.signup(request))
                .isInstanceOf(UserAlreadyExistsException.class)
                .hasMessageContaining("john");
    }

    @Test
    void shouldRethrowKeycloakException_whenSignupFailsWithNon409() {
        var request = new SignupRequest("john", "john@example.com", "John", "Doe", "password123");
        when(keycloakAuthAdapter.createUser("john", "john@example.com", "John", "Doe", "password123"))
                .thenThrow(new KeycloakCommunicationException("Keycloak operation 'createUser' failed: 500"));

        assertThatThrownBy(() -> authService.signup(request))
                .isInstanceOf(KeycloakCommunicationException.class)
                .hasMessageContaining("500");
    }

    // --- login ---

    @Test
    void shouldLoginSuccessfully() {
        var request = new LoginRequest("john", "password123");
        var keycloakResponse = keycloakTokenResponse();
        when(keycloakAuthAdapter.authenticate("john", "password123"))
                .thenReturn(keycloakResponse);

        TokenResponse result = authService.login(request);

        assertThat(result.accessToken()).isEqualTo("access-token");
        assertThat(result.refreshToken()).isEqualTo("refresh-token");
        assertThat(result.expiresIn()).isEqualTo(300);
    }

    @Test
    void shouldThrowInvalidCredentials_whenKeycloakReturns401() {
        var request = new LoginRequest("john", "wrong-password");
        when(keycloakAuthAdapter.authenticate("john", "wrong-password"))
                .thenThrow(new KeycloakCommunicationException(
                        "Keycloak operation 'authenticate' failed: 401 Unauthorized"));

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(InvalidCredentialsException.class)
                .hasMessage("Invalid username or password");
    }

    @Test
    void shouldRethrowKeycloakException_whenLoginFailsWithNon401() {
        var request = new LoginRequest("john", "password123");
        when(keycloakAuthAdapter.authenticate("john", "password123"))
                .thenThrow(new KeycloakCommunicationException("Keycloak operation 'authenticate' failed: 503"));

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(KeycloakCommunicationException.class)
                .hasMessageContaining("503");
    }

    // --- refreshToken ---

    @Test
    void shouldRefreshTokenSuccessfully() {
        var request = new RefreshRequest("old-refresh-token");
        var keycloakResponse = keycloakTokenResponse();
        when(keycloakAuthAdapter.refreshToken("old-refresh-token"))
                .thenReturn(keycloakResponse);

        TokenResponse result = authService.refreshToken(request);

        assertThat(result.accessToken()).isEqualTo("access-token");
        assertThat(result.refreshToken()).isEqualTo("refresh-token");
    }

    @Test
    void shouldThrowTokenRefreshException_whenKeycloakReturns400() {
        var request = new RefreshRequest("expired-token");
        when(keycloakAuthAdapter.refreshToken("expired-token"))
                .thenThrow(new KeycloakCommunicationException(
                        "Keycloak operation 'refreshToken' failed: 400 Bad Request"));

        assertThatThrownBy(() -> authService.refreshToken(request))
                .isInstanceOf(TokenRefreshException.class)
                .hasMessage("Refresh token is invalid or expired");
    }

    @Test
    void shouldRethrowKeycloakException_whenRefreshFailsWithNon400() {
        var request = new RefreshRequest("some-token");
        when(keycloakAuthAdapter.refreshToken("some-token"))
                .thenThrow(new KeycloakCommunicationException("Keycloak operation 'refreshToken' failed: 502"));

        assertThatThrownBy(() -> authService.refreshToken(request))
                .isInstanceOf(KeycloakCommunicationException.class)
                .hasMessageContaining("502");
    }

    // --- changePassword ---

    @Test
    void shouldChangePasswordSuccessfully() {
        var request = new ChangePasswordRequest("new-password-123");
        doNothing().when(keycloakAuthAdapter).changePassword("user-id-123", "new-password-123");

        authService.changePassword("user-id-123", request);

        verify(keycloakAuthAdapter).changePassword("user-id-123", "new-password-123");
    }

    @Test
    void shouldPropagateException_whenChangePasswordFails() {
        var request = new ChangePasswordRequest("new-password-123");
        doThrow(new KeycloakCommunicationException("Keycloak operation 'changePassword' failed: 500"))
                .when(keycloakAuthAdapter).changePassword("user-id-123", "new-password-123");

        assertThatThrownBy(() -> authService.changePassword("user-id-123", request))
                .isInstanceOf(KeycloakCommunicationException.class);
    }

    // --- test helpers ---

    private KeycloakTokenResponse keycloakTokenResponse() {
        return new KeycloakTokenResponse(
                "access-token",
                "refresh-token",
                300,
                1800,
                "Bearer");
    }
}
