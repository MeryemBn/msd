package ma.skylark.msd.config;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class KeycloakPropertiesTest {

    private final KeycloakProperties properties = new KeycloakProperties(
            "https://auth.example.com", "my-realm", "my-client", "my-secret", null, null);

    @Test
    void tokenEndpoint_shouldBuildCorrectUrl() {
        assertThat(properties.tokenEndpoint())
                .isEqualTo("https://auth.example.com/realms/my-realm/protocol/openid-connect/token");
    }

    @Test
    void adminUsersEndpoint_shouldBuildCorrectUrl() {
        assertThat(properties.adminUsersEndpoint())
                .isEqualTo("https://auth.example.com/admin/realms/my-realm/users");
    }

    @Test
    void tokenEndpoint_shouldHandleTrailingSlashOnServerUrl() {
        var props = new KeycloakProperties("https://auth.example.com/", "realm", "c", "s", null, null);
        assertThat(props.tokenEndpoint()).contains("/realms/realm/protocol/openid-connect/token");
    }
}
