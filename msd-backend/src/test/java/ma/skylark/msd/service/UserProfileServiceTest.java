package ma.skylark.msd.service;

import ma.skylark.msd.controller.dto.UpdateProfileRequest;
import ma.skylark.msd.controller.dto.UserProfileResponse;
import ma.skylark.msd.domain.entity.UserProfile;
import ma.skylark.msd.domain.exception.ProfileNotFoundException;
import ma.skylark.msd.repository.UserProfileRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class UserProfileServiceTest {

    @Mock
    private UserProfileRepository userProfileRepository;

    @InjectMocks
    private UserProfileService userProfileService;

    // --- getProfile ---

    @Test
    void shouldReturnProfile_whenExists() {
        var profile = profileWithInfo();
        when(userProfileRepository.findByKeycloakId("kc-123")).thenReturn(Optional.of(profile));

        UserProfileResponse result = userProfileService.getProfile("kc-123");

        assertThat(result.firstName()).isEqualTo("John");
        assertThat(result.lastName()).isEqualTo("Doe");
        assertThat(result.phoneNumber()).isEqualTo("+212600000000");
        assertThat(result.address()).isEqualTo("123 Main St");
        assertThat(result.city()).isEqualTo("Casablanca");
    }

    @Test
    void shouldThrowProfileNotFound_whenProfileDoesNotExist() {
        when(userProfileRepository.findByKeycloakId("kc-unknown")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> userProfileService.getProfile("kc-unknown"))
                .isInstanceOf(ProfileNotFoundException.class)
                .hasMessageContaining("kc-unknown");
    }

    // --- createProfile ---

    @Test
    void shouldCreateProfileWithInitialInfo() {
        when(userProfileRepository.save(any(UserProfile.class)))
                .thenAnswer(invocation -> {
                    UserProfile p = invocation.getArgument(0);
                    ReflectionTestUtils.setField(p, "id", 100L);
                    return p;
                });

        UserProfileResponse result = userProfileService.createProfile("kc-new", "John", "Doe", "john@example.com");

        assertThat(result.id()).isNotNull();
        assertThat(result.firstName()).isEqualTo("John");
        assertThat(result.lastName()).isEqualTo("Doe");
        assertThat(result.email()).isEqualTo("john@example.com");

        ArgumentCaptor<UserProfile> captor = ArgumentCaptor.forClass(UserProfile.class);
        verify(userProfileRepository).save(captor.capture());
        assertThat(captor.getValue().getKeycloakId()).isEqualTo("kc-new");
        assertThat(captor.getValue().getFirstName()).isEqualTo("John");
        assertThat(captor.getValue().getLastName()).isEqualTo("Doe");
        assertThat(captor.getValue().getEmail()).isEqualTo("john@example.com");
    }

    // --- updateProfile ---

    @Test
    void shouldUpdateProfile_whenExists() {
        var profile = new UserProfile("kc-123");
        when(userProfileRepository.findByKeycloakId("kc-123")).thenReturn(Optional.of(profile));
        when(userProfileRepository.save(any(UserProfile.class)))
                .thenAnswer(invocation -> {
                    UserProfile p = invocation.getArgument(0);
                    ReflectionTestUtils.setField(p, "id", 100L);
                    return p;
                });

        var request = new UpdateProfileRequest("Jane", "Smith", "+212611111111", "456 Oak Ave", "Rabat");

        UserProfileResponse result = userProfileService.updateProfile("kc-123", request);

        assertThat(result.firstName()).isEqualTo("Jane");
        assertThat(result.lastName()).isEqualTo("Smith");
        assertThat(result.phoneNumber()).isEqualTo("+212611111111");
        assertThat(result.address()).isEqualTo("456 Oak Ave");
        assertThat(result.city()).isEqualTo("Rabat");
    }

    @Test
    void shouldThrowProfileNotFound_whenUpdatingNonExistentProfile() {
        when(userProfileRepository.findByKeycloakId("kc-missing")).thenReturn(Optional.empty());

        var request = new UpdateProfileRequest("Jane", "Smith", "+212611111111", "456 Oak Ave", "Rabat");

        assertThatThrownBy(() -> userProfileService.updateProfile("kc-missing", request))
                .isInstanceOf(ProfileNotFoundException.class)
                .hasMessageContaining("kc-missing");
    }

    // --- helpers ---

    private UserProfile profileWithInfo() {
        var profile = new UserProfile("kc-123");
        profile.updatePersonalInfo("John", "Doe", "+212600000000");
        profile.updateAddress("123 Main St", "Casablanca");
        return profile;
    }
}
