package ma.skylark.msd.controller;

import ma.skylark.msd.config.SecurityConfig;
import ma.skylark.msd.controller.dto.UpdateProfileRequest;
import ma.skylark.msd.controller.dto.UserProfileResponse;
import ma.skylark.msd.domain.exception.ProfileNotFoundException;
import ma.skylark.msd.exception.GlobalExceptionHandler;
import ma.skylark.msd.service.UserProfileService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Slice test for UserProfileController.
 * Both endpoints require JWT authentication.
 */
@WebMvcTest(UserProfileController.class)
@Import({ GlobalExceptionHandler.class, SecurityConfig.class })
class UserProfileControllerTest {

        @Autowired
        private MockMvc mockMvc;

        @MockitoBean
        private UserProfileService userProfileService;

        // ===================== GET /api/profiles/me =====================

        @Test
        void getProfile_shouldReturn200_whenAuthenticated() throws Exception {
                var response = sampleProfileResponse();
                when(userProfileService.getProfile("user-id")).thenReturn(response);

                mockMvc.perform(get("/api/profiles/me")
                                .with(jwt().jwt(j -> j.subject("user-id"))))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.firstName").value("John"))
                                .andExpect(jsonPath("$.lastName").value("Doe"))
                                .andExpect(jsonPath("$.phoneNumber").value("+212600000000"))
                                .andExpect(jsonPath("$.address").value("123 Main St"))
                                .andExpect(jsonPath("$.city").value("Casablanca"));
        }

        @Test
        void getProfile_shouldReturn401_whenNoJwt() throws Exception {
                mockMvc.perform(get("/api/profiles/me"))
                                .andExpect(status().isUnauthorized());
        }

        @Test
        void getProfile_shouldReturn404_whenProfileNotFound() throws Exception {
                when(userProfileService.getProfile("user-id"))
                                .thenThrow(new ProfileNotFoundException("Profile not found for user 'user-id'"));

                mockMvc.perform(get("/api/profiles/me")
                                .with(jwt().jwt(j -> j.subject("user-id"))))
                                .andExpect(status().isNotFound())
                                .andExpect(jsonPath("$.error").value("PROFILE_NOT_FOUND"))
                                .andExpect(jsonPath("$.status").value(404));
        }

        // ===================== PUT /api/profiles/me =====================

        @Test
        void updateProfile_shouldReturn200_whenValid() throws Exception {
                var response = sampleProfileResponse();
                when(userProfileService.updateProfile(eq("user-id"), any(UpdateProfileRequest.class)))
                                .thenReturn(response);

                mockMvc.perform(put("/api/profiles/me")
                                .with(jwt().jwt(j -> j.subject("user-id")))
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "firstName": "John",
                                                    "lastName": "Doe",
                                                    "phoneNumber": "+212600000000",
                                                    "address": "123 Main St",
                                                    "city": "Casablanca"
                                                }
                                                """))
                                .andExpect(status().isOk())
                                .andExpect(jsonPath("$.firstName").value("John"))
                                .andExpect(jsonPath("$.lastName").value("Doe"));
        }

        @Test
        void updateProfile_shouldReturn401_whenNoJwt() throws Exception {
                mockMvc.perform(put("/api/profiles/me")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "firstName": "John"
                                                }
                                                """))
                                .andExpect(status().isUnauthorized());
        }

        @Test
        void updateProfile_shouldReturn400_whenFirstNameTooLong() throws Exception {
                mockMvc.perform(put("/api/profiles/me")
                                .with(jwt().jwt(j -> j.subject("user-id")))
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "firstName": "%s"
                                                }
                                                """.formatted("x".repeat(101))))
                                .andExpect(status().isBadRequest())
                                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
        }

        @Test
        void updateProfile_shouldReturn404_whenProfileNotFound() throws Exception {
                when(userProfileService.updateProfile(eq("user-id"), any(UpdateProfileRequest.class)))
                                .thenThrow(new ProfileNotFoundException("Profile not found"));

                mockMvc.perform(put("/api/profiles/me")
                                .with(jwt().jwt(j -> j.subject("user-id")))
                                .contentType(MediaType.APPLICATION_JSON)
                                .content("""
                                                {
                                                    "firstName": "John"
                                                }
                                                """))
                                .andExpect(status().isNotFound())
                                .andExpect(jsonPath("$.error").value("PROFILE_NOT_FOUND"));
        }

        // --- helpers ---

        private UserProfileResponse sampleProfileResponse() {
                return new UserProfileResponse(
                                99L,
                                "John",
                                "Doe",
                                "john.doe@example.com",
                                "+212600000000",
                                "123 Main St",
                                "Casablanca",
                                Instant.now(),
                                Instant.now());
        }
}
