package ma.skylark.msd.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

/**
 * Provides pre-configured RestClient beans for communicating with Keycloak.
 * <p>
 * Two clients are needed:
 * <ul>
 * <li>{@code keycloakTokenClient} — calls the public token endpoint (no admin
 * auth)</li>
 * <li>{@code keycloakAdminClient} — calls the admin REST API (requires admin
 * token)</li>
 * </ul>
 */
@Configuration
@EnableConfigurationProperties(KeycloakProperties.class)
public class KeycloakAdminClientConfig {

    @Bean
    public RestClient keycloakTokenClient(KeycloakProperties properties) {
        return RestClient.builder()
                .baseUrl(properties.tokenEndpoint())
                .build();
    }

    @Bean
    public RestClient keycloakAdminClient(KeycloakProperties properties) {
        return RestClient.builder()
                .baseUrl(properties.adminUsersEndpoint())
                .build();
    }
}
