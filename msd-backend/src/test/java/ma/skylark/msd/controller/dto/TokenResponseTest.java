package ma.skylark.msd.controller.dto;

import ma.skylark.msd.integration.keycloak.dto.KeycloakTokenResponse;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class TokenResponseTest {

    @Test
    void from_shouldMapAllFieldsFromKeycloakResponse() {
        var keycloakResponse = new KeycloakTokenResponse(
                "access-token-value",
                "refresh-token-value",
                300,
                1800,
                "Bearer");

        var result = TokenResponse.from(keycloakResponse);

        assertThat(result.accessToken()).isEqualTo("access-token-value");
        assertThat(result.refreshToken()).isEqualTo("refresh-token-value");
        assertThat(result.expiresIn()).isEqualTo(300);
        assertThat(result.refreshExpiresIn()).isEqualTo(1800);
        assertThat(result.tokenType()).isEqualTo("Bearer");
    }

    @Test
    void from_shouldHandleNullFields() {
        var keycloakResponse = new KeycloakTokenResponse(null, null, 0, 0, null);

        var result = TokenResponse.from(keycloakResponse);

        assertThat(result.accessToken()).isNull();
        assertThat(result.refreshToken()).isNull();
        assertThat(result.expiresIn()).isZero();
        assertThat(result.tokenType()).isNull();
    }
}
