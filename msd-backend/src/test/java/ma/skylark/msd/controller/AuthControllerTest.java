package ma.skylark.msd.controller;

import ma.skylark.msd.config.SecurityConfig;
import ma.skylark.msd.controller.dto.*;
import ma.skylark.msd.domain.exception.InvalidCredentialsException;
import ma.skylark.msd.domain.exception.TokenRefreshException;
import ma.skylark.msd.domain.exception.UserAlreadyExistsException;
import ma.skylark.msd.exception.GlobalExceptionHandler;
import ma.skylark.msd.integration.keycloak.exception.KeycloakCommunicationException;
import ma.skylark.msd.service.AuthService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Slice test for AuthController.
 * <p>
 * Security filters are active — public endpoints use csrf() post-processor,
 * authenticated endpoints use jwt() post-processor.
 */
@WebMvcTest(AuthController.class)
@Import({ GlobalExceptionHandler.class, SecurityConfig.class })
class AuthControllerTest {

        @Autowired
        private MockMvc mockMvc;

        @MockitoBean
        private AuthService authService;

        // ===================== signup =====================

        @Test
        void signup_shouldReturn201_whenValid() throws Exception {
                doNothing().when(authService).signup(any(SignupRequest.class));

                mockMvc.perform(post("/api/auth/signup")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "username": "john",
                                                    "email": "john@example.com",
                                                    "firstName": "John",
                                                    "lastName": "Doe",
                                                    "password": "password123"
                                                }
                                                """))
                                .andExpect(status().isCreated());

                verify(authService).signup(any(SignupRequest.class));
        }

        @Test
        void signup_shouldReturn400_whenUsernameBlank() throws Exception {
                mockMvc.perform(post("/api/auth/signup")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "username": "",
                                                    "email": "john@example.com",
                                                    "firstName": "John",
                                                    "lastName": "Doe",
                                                    "password": "password123"
                                                }
                                                """))
                                .andExpect(status().isBadRequest())
                                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
        }

        @Test
        void signup_shouldReturn400_whenEmailInvalid() throws Exception {
                mockMvc.perform(post("/api/auth/signup")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "username": "john",
                                                    "email": "not-an-email",
                                                    "firstName": "John",
                                                    "lastName": "Doe",
                                                    "password": "password123"
                                                }
                                                """))
                                .andExpect(status().isBadRequest())
                                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
        }

        @Test
        void signup_shouldReturn400_whenPasswordTooShort() throws Exception {
                mockMvc.perform(post("/api/auth/signup")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "username": "john",
                                                    "email": "john@example.com",
                                                    "firstName": "John",
                                                    "lastName": "Doe",
                                                    "password": "short"
                                                }
                                                """))
                                .andExpect(status().isBadRequest())
                                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
        }

        @Test
        void signup_shouldReturn409_whenUserExists() throws Exception {
                doThrow(new UserAlreadyExistsException("User already exists"))
                                .when(authService).signup(any(SignupRequest.class));

                mockMvc.perform(post("/api/auth/signup")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "username": "john",
                                                    "email": "john@example.com",
                                                    "firstName": "John",
                                                    "lastName": "Doe",
                                                    "password": "password123"
                                                }
                                                """))
                                .andExpect(status().isConflict())
                                .andExpect(jsonPath("$.error").value("USER_ALREADY_EXISTS"))
                                .andExpect(jsonPath("$.status").value(409));
        }

        // ===================== login =====================

        @Test
        void login_shouldReturn200WithTokens_whenValid() throws Exception {
                var tokenResponse = new TokenResponse("access-token", "refresh-token", 300, 1800, "Bearer");
                when(authService.login(any(LoginRequest.class))).thenReturn(tokenResponse);

                mockMvc.perform(post("/api/auth/login")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "username": "john",
                                                    "password": "password123"
                                                }
                                                """))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.accessToken").value("access-token"))
                                .andExpect(jsonPath("$.refreshToken").value("refresh-token"))
                                .andExpect(jsonPath("$.expiresIn").value(300))
                                .andExpect(jsonPath("$.tokenType").value("Bearer"));
        }

        @Test
        void login_shouldReturn400_whenUsernameBlank() throws Exception {
                mockMvc.perform(post("/api/auth/login")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "username": "",
                                                    "password": "password123"
                                                }
                                                """))
                                .andExpect(status().isBadRequest())
                                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
        }

        @Test
        void login_shouldReturn401_whenInvalidCredentials() throws Exception {
                when(authService.login(any(LoginRequest.class)))
                                .thenThrow(new InvalidCredentialsException("Invalid username or password"));

                mockMvc.perform(post("/api/auth/login")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "username": "john",
                                                    "password": "wrong"
                                                }
                                                """))
                                .andExpect(status().isUnauthorized())
                                .andExpect(jsonPath("$.error").value("INVALID_CREDENTIALS"))
                                .andExpect(jsonPath("$.status").value(401));
        }

        // ===================== refresh =====================

        @Test
        void refresh_shouldReturn200WithTokens_whenValid() throws Exception {
                var tokenResponse = new TokenResponse("new-access", "new-refresh", 300, 1800, "Bearer");
                when(authService.refreshToken(any(RefreshRequest.class))).thenReturn(tokenResponse);

                mockMvc.perform(post("/api/auth/refresh")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "refreshToken": "old-refresh-token"
                                                }
                                                """))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.accessToken").value("new-access"))
                                .andExpect(jsonPath("$.refreshToken").value("new-refresh"));
        }

        @Test
        void refresh_shouldReturn400_whenRefreshTokenBlank() throws Exception {
                mockMvc.perform(post("/api/auth/refresh")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "refreshToken": ""
                                                }
                                                """))
                                .andExpect(status().isBadRequest())
                                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
        }

        @Test
        void refresh_shouldReturn401_whenTokenExpired() throws Exception {
                when(authService.refreshToken(any(RefreshRequest.class)))
                                .thenThrow(new TokenRefreshException("Refresh token is invalid or expired"));

                mockMvc.perform(post("/api/auth/refresh")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "refreshToken": "expired-token"
                                                }
                                                """))
                                .andExpect(status().isUnauthorized())
                                .andExpect(jsonPath("$.error").value("TOKEN_REFRESH_FAILED"))
                                .andExpect(jsonPath("$.status").value(401));
        }

        // ===================== change-password =====================

        @Test
        void changePassword_shouldReturn204_whenValid() throws Exception {
                doNothing().when(authService).changePassword(eq("user-id"), any(ChangePasswordRequest.class));

                mockMvc.perform(post("/api/auth/change-password")
                                .with(jwt().jwt(j -> j.subject("user-id")))
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "newPassword": "newPassword123"
                                                }
                                                """))
                                .andExpect(status().isNoContent());

                verify(authService).changePassword(eq("user-id"), any(ChangePasswordRequest.class));
        }

        @Test
        void changePassword_shouldReturn400_whenPasswordTooShort() throws Exception {
                mockMvc.perform(post("/api/auth/change-password")
                                .with(jwt().jwt(j -> j.subject("user-id")))
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "newPassword": "short"
                                                }
                                                """))
                                .andExpect(status().isBadRequest())
                                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
        }

        // ===================== error envelope =====================

        @Test
        void shouldReturn502_whenKeycloakUnavailable() throws Exception {
                when(authService.login(any(LoginRequest.class)))
                                .thenThrow(new KeycloakCommunicationException("Connection refused"));

                mockMvc.perform(post("/api/auth/login")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "username": "john",
                                                    "password": "password123"
                                                }
                                                """))
                                .andExpect(status().isBadGateway())
                                .andExpect(jsonPath("$.error").value("IDENTITY_PROVIDER_ERROR"))
                                .andExpect(jsonPath("$.message")
                                                .value("Authentication service is temporarily unavailable"))
                                .andExpect(jsonPath("$.status").value(502))
                                .andExpect(jsonPath("$.timestamp").exists());
        }

        @Test
        void errorResponse_shouldHaveConsistentShape() throws Exception {
                doThrow(new UserAlreadyExistsException("User exists"))
                                .when(authService).signup(any(SignupRequest.class));

                mockMvc.perform(post("/api/auth/signup")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "username": "john",
                                                    "email": "john@example.com",
                                                    "firstName": "John",
                                                    "lastName": "Doe",
                                                    "password": "password123"
                                                }
                                                """))
                                .andExpect(jsonPath("$.status").isNumber())
                                .andExpect(jsonPath("$.error").isString())
                                .andExpect(jsonPath("$.message").isString())
                                .andExpect(jsonPath("$.timestamp").isString());
        }
}
