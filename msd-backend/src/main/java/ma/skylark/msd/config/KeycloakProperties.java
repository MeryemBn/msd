package ma.skylark.msd.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Typed configuration for Keycloak connectivity.
 * Bound from {@code app.keycloak.*} in application.yaml.
 */
@ConfigurationProperties(prefix = "app.keycloak")
public record KeycloakProperties(
        String serverUrl,
        String realm,
        String clientId,
        String clientSecret,
        String testUser,
        String testPassword,
        Admin admin) {

    public record Admin(
            String clientId,
            String username,
            String password) {
    }

    /**
     * Returns the full token endpoint URL for this realm.
     */
    public String tokenEndpoint() {
        return serverUrl + "/realms/" + realm + "/protocol/openid-connect/token";
    }

    /**
     * Returns the admin REST API base URL for user management.
     */
    public String adminUsersEndpoint() {
        return serverUrl + "/admin/realms/" + realm + "/users";
    }
}
