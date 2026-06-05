package ma.skylark.msd.integration;

import ma.skylark.msd.config.KeycloakProperties;
import ma.skylark.msd.integration.keycloak.KeycloakAuthAdapter;
import ma.skylark.msd.integration.keycloak.exception.KeycloakCommunicationException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.resource.RealmResource;
import org.keycloak.admin.client.resource.UsersResource;
import jakarta.ws.rs.core.Response;
import org.mockito.Mockito;
import java.net.URI;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.AssertionsForClassTypes.assertThat;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.*;
import static org.springframework.test.web.client.response.MockRestResponseCreators.*;

/**
 * Unit test for KeycloakAuthAdapter.
 * Uses MockRestServiceServer to intercept and verify RestClient HTTP calls.
 */
class KeycloakAuthAdapterTest {

    private static final KeycloakProperties PROPERTIES = new KeycloakProperties(
            "http://localhost:8080", "test-realm", "test-client", "test-secret", null, null);

    private static final String TOKEN_ENDPOINT = "http://localhost:8080/realms/test-realm/protocol/openid-connect/token";
    private static final String ADMIN_USERS_ENDPOINT = "http://localhost:8080/admin/realms/test-realm/users";

    private static final String TOKEN_RESPONSE_JSON = """
            {
                "access_token": "user-access-token",
                "refresh_token": "user-refresh-token",
                "expires_in": 300,
                "refresh_expires_in": 1800,
                "token_type": "Bearer"
            }
            """;

    private static final String ADMIN_TOKEN_RESPONSE_JSON = """
            {
                "access_token": "admin-access-token",
                "refresh_token": null,
                "expires_in": 300,
                "refresh_expires_in": 0,
                "token_type": "Bearer"
            }
            """;

    private MockRestServiceServer tokenServer;
    private MockRestServiceServer adminServer;
    private KeycloakAuthAdapter adapter;
    private Keycloak keycloak;
    private RealmResource realmResource;
    private UsersResource usersResource;

    @BeforeEach
    void setUp() {
        var tokenBuilder = RestClient.builder().baseUrl(TOKEN_ENDPOINT);
        var adminBuilder = RestClient.builder().baseUrl(ADMIN_USERS_ENDPOINT);

        tokenServer = MockRestServiceServer.bindTo(tokenBuilder).build();
        adminServer = MockRestServiceServer.bindTo(adminBuilder).build();

        keycloak = Mockito.mock(Keycloak.class);
        realmResource = Mockito.mock(RealmResource.class);
        usersResource = Mockito.mock(UsersResource.class);
        Mockito.when(keycloak.realm(Mockito.anyString())).thenReturn(realmResource);
        Mockito.when(realmResource.users()).thenReturn(usersResource);

        adapter = new KeycloakAuthAdapter(tokenBuilder.build(), adminBuilder.build(), PROPERTIES, keycloak);
    }

    /**
     * Stubs the token endpoint to return a valid admin token.
     * Used by createUser and changePassword tests.
     */
    private void expectAdminTokenRequest() {
        tokenServer.expect(requestTo(TOKEN_ENDPOINT))
                .andExpect(method(HttpMethod.POST))
                .andExpect(content().contentType(MediaType.APPLICATION_FORM_URLENCODED))
                .andRespond(withSuccess(ADMIN_TOKEN_RESPONSE_JSON, MediaType.APPLICATION_JSON));
    }

    @Nested
    class Authenticate {

        @Test
        void shouldReturnTokenResponse_whenCredentialsValid() {
            tokenServer.expect(requestTo(TOKEN_ENDPOINT))
                    .andExpect(method(HttpMethod.POST))
                    .andExpect(content().contentType(MediaType.APPLICATION_FORM_URLENCODED))
                    .andRespond(withSuccess(TOKEN_RESPONSE_JSON, MediaType.APPLICATION_JSON));

            var result = adapter.authenticate("john", "password123");

            assertThat(result.access_token()).isEqualTo("user-access-token");
            assertThat(result.refresh_token()).isEqualTo("user-refresh-token");
            assertThat(result.expires_in()).isEqualTo(300);
            tokenServer.verify();
        }

        @Test
        void shouldThrowKeycloakCommunicationException_whenServerError() {
            tokenServer.expect(requestTo(TOKEN_ENDPOINT))
                    .andRespond(withServerError());

            assertThatThrownBy(() -> adapter.authenticate("john", "wrong"))
                    .isInstanceOf(KeycloakCommunicationException.class)
                    .hasMessageContaining("authenticate");
        }
    }

    @Nested
    class RefreshToken {

        @Test
        void shouldReturnNewTokens_whenRefreshTokenValid() {
            tokenServer.expect(requestTo(TOKEN_ENDPOINT))
                    .andExpect(method(HttpMethod.POST))
                    .andRespond(withSuccess(TOKEN_RESPONSE_JSON, MediaType.APPLICATION_JSON));

            var result = adapter.refreshToken("old-refresh-token");

            assertThat(result.access_token()).isEqualTo("user-access-token");
            assertThat(result.refresh_token()).isEqualTo("user-refresh-token");
            tokenServer.verify();
        }

        @Test
        void shouldThrowKeycloakCommunicationException_whenRefreshFails() {
            tokenServer.expect(requestTo(TOKEN_ENDPOINT))
                    .andRespond(withServerError());

            assertThatThrownBy(() -> adapter.refreshToken("expired-token"))
                    .isInstanceOf(KeycloakCommunicationException.class)
                    .hasMessageContaining("refreshToken");
        }
    }

    @Nested
    class CreateUser {

        @Test
        void shouldReturnUserId_whenResponseIs201() {
            var response = Mockito.mock(Response.class);
            Mockito.when(response.getStatus()).thenReturn(201);
            Mockito.when(response.getLocation()).thenReturn(URI.create(ADMIN_USERS_ENDPOINT + "/abc-123"));
            Mockito.when(usersResource.create(Mockito.any())).thenReturn(response);

            var result = adapter.createUser("john", "john@example.com", "John", "Doe", "password123");

            assertThat(result).isEqualTo("abc-123");
            Mockito.verify(usersResource).create(Mockito.any());
        }

        @Test
        void shouldReturnNull_whenNoLocationHeader() {
            var response = Mockito.mock(Response.class);
            Mockito.when(response.getStatus()).thenReturn(201);
            Mockito.when(response.getLocation()).thenReturn(null);
            Mockito.when(usersResource.create(Mockito.any())).thenReturn(response);

            var result = adapter.createUser("john", "john@example.com", "John", "Doe", "password123");

            assertThat(result).isNull();
        }

        @Test
        void shouldThrowKeycloakCommunicationException_whenCreateFailsWith409() {
            var response = Mockito.mock(Response.class);
            Mockito.when(response.getStatus()).thenReturn(409);
            Mockito.when(usersResource.create(Mockito.any())).thenReturn(response);

            assertThatThrownBy(() -> adapter.createUser("john", "john@example.com", "John", "Doe", "pass"))
                    .isInstanceOf(KeycloakCommunicationException.class)
                    .hasMessageContaining("409 Conflict");
        }
    }

    @Nested
    class ChangePassword {

        @Test
        void shouldSucceed_whenKeycloakAcceptsPasswordChange() {
            expectAdminTokenRequest();

            adminServer.expect(requestTo(ADMIN_USERS_ENDPOINT + "/user-id-123/reset-password"))
                    .andExpect(method(HttpMethod.PUT))
                    .andExpect(header("Authorization", "Bearer admin-access-token"))
                    .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                    .andRespond(withStatus(HttpStatus.NO_CONTENT));

            adapter.changePassword("user-id-123", "newPassword");

            tokenServer.verify();
            adminServer.verify();
        }

        @Test
        void shouldThrowKeycloakCommunicationException_whenChangeFails() {
            expectAdminTokenRequest();

            adminServer.expect(requestTo(ADMIN_USERS_ENDPOINT + "/user-id-123/reset-password"))
                    .andRespond(withServerError());

            assertThatThrownBy(() -> adapter.changePassword("user-id-123", "newPassword"))
                    .isInstanceOf(KeycloakCommunicationException.class)
                    .hasMessageContaining("changePassword");
        }
    }

    @Nested
    class ObtainAdminToken {

        @Test
        void shouldThrow_whenAdminTokenResponseEmpty() {
            tokenServer.expect(requestTo(TOKEN_ENDPOINT))
                    .andRespond(withSuccess("""
                            {
                                "access_token": null,
                                "refresh_token": null,
                                "expires_in": 0,
                                "refresh_expires_in": 0,
                                "token_type": null
                            }
                            """, MediaType.APPLICATION_JSON));

            assertThatThrownBy(() -> adapter.changePassword("user-id", "pass"))
                    .isInstanceOf(KeycloakCommunicationException.class)
                    .hasMessageContaining("Failed to obtain admin token");
        }
    }
}
