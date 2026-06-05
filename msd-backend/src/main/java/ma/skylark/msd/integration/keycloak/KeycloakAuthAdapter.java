package ma.skylark.msd.integration.keycloak;

import jakarta.ws.rs.core.Response;
import ma.skylark.msd.config.KeycloakProperties;
import ma.skylark.msd.integration.keycloak.dto.KeycloakTokenResponse;
import ma.skylark.msd.integration.keycloak.exception.KeycloakCommunicationException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;

import java.util.List;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.representations.idm.CredentialRepresentation;
import org.keycloak.representations.idm.UserRepresentation;

/**
 * Adapter wrapping Keycloak REST API calls for authentication operations.
 * <p>
 * Uses:
 * <ul>
 * <li>{@code keycloakTokenClient} — for public token operations (login, refresh)</li>
 * <li>{@code Keycloak} bean — for admin operations (create user, reset password, etc.)</li>
 * </ul>
 */
@Slf4j
@Component
public class KeycloakAuthAdapter {

    private final RestClient tokenClient;
    private final KeycloakProperties properties;
    private final Keycloak keycloak;

    public KeycloakAuthAdapter(
            @Qualifier("keycloakTokenClient") RestClient tokenClient,
            KeycloakProperties properties,
            Keycloak keycloak) {
        this.tokenClient = tokenClient;
        this.properties = properties;
        this.keycloak = keycloak;
    }

    /**
     * Creates a new user in Keycloak with role assignment and explicit email verification trigger.
     */
    public String createUser(String username, String email, String firstName, String lastName, String password, String role) {
        var credential = new CredentialRepresentation();
        credential.setType(CredentialRepresentation.PASSWORD);
        credential.setValue(password);
        credential.setTemporary(false);

        var userRepresentation = new UserRepresentation();
        userRepresentation.setUsername(username);
        userRepresentation.setEmail(email);
        userRepresentation.setFirstName(firstName);
        userRepresentation.setLastName(lastName);
        userRepresentation.setEnabled(true);

        userRepresentation.setEmailVerified(false);
        userRepresentation.setRequiredActions(List.of("VERIFY_EMAIL"));
        // ----------------------------------------

        userRepresentation.setCredentials(List.of(credential));

        try (Response response = keycloak.realm(properties.realm()).users().create(userRepresentation)) {
            if (response.getStatus() == 201) {
                var location = response.getLocation();
                if (location != null) {
                    var path = location.getPath();
                    String userId = path.substring(path.lastIndexOf('/') + 1);

                    sendVerificationEmail(userId, email);

                    try {
                        var roleRep = keycloak.realm(properties.realm()).roles().get(role).toRepresentation();
                        keycloak.realm(properties.realm()).users().get(userId).roles().realmLevel().add(List.of(roleRep));
                    } catch (Exception e) {
                        log.error("Erreur lors de l'assignation du rôle {} à l'utilisateur {}", role, userId);
                    }

                    return userId;
                }
                return null;
            } else if (response.getStatus() == 409) {
                throw new KeycloakCommunicationException("L'utilisateur existe déjà dans Keycloak");
            } else {
                throw new KeycloakCommunicationException("Keycloak operation 'createUser' failed: " + response.getStatus());
            }
        } catch (Exception e) {
            if (e instanceof KeycloakCommunicationException) throw (KeycloakCommunicationException) e;
            throw translateException("createUser", new RestClientException(e.getMessage(), e));
        }
    }

    /**
     * Envoie l'email de vérification de manière asynchrone pour ne pas bloquer le signup.
     */
    @Async
    public void sendVerificationEmail(String userId, String email) {
        try {
            keycloak.realm(properties.realm()).users().get(userId).sendVerifyEmail();
            log.info("Email de vérification envoyé (asynchrone) à : {}", email);
        } catch (Exception e) {
            log.error("Erreur (asynchrone) lors de l'envoi de l'email de vérification à {} : {}", email, e.getMessage());
        }
    }

    public KeycloakTokenResponse authenticate(String username, String password) {
        var formData = new LinkedMultiValueMap<String, String>();
        formData.add("grant_type", "password");
        formData.add("client_id", properties.clientId());
        formData.add("client_secret", properties.clientSecret());
        formData.add("username", username);
        formData.add("password", password);

        try {
            return tokenClient.post()
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(formData)
                    .retrieve()
                    .body(KeycloakTokenResponse.class);
        } catch (RestClientException e) {
            throw translateException("authenticate", e);
        }
    }

    public KeycloakTokenResponse refreshToken(String refreshToken) {
        var formData = new LinkedMultiValueMap<String, String>();
        formData.add("grant_type", "refresh_token");
        formData.add("client_id", properties.clientId());
        formData.add("client_secret", properties.clientSecret());
        formData.add("refresh_token", refreshToken);

        try {
            return tokenClient.post()
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(formData)
                    .retrieve()
                    .body(KeycloakTokenResponse.class);
        } catch (RestClientException e) {
            throw translateException("refreshToken", e);
        }
    }

    /**
     * Changes a user's password using the official Keycloak admin client.
     */
    public void changePassword(String userId, String newPassword) {
        var credential = new CredentialRepresentation();
        credential.setType(CredentialRepresentation.PASSWORD);
        credential.setValue(newPassword);
        credential.setTemporary(false);

        try {
            keycloak.realm(properties.realm())
                    .users()
                    .get(userId)
                    .resetPassword(credential);
            log.info("Mot de passe changé avec succès pour l'utilisateur ID: {}", userId);
        } catch (Exception e) {
            log.error("Erreur lors du changement de mot de passe Keycloak pour {}: {}", userId, e.getMessage());
            throw new KeycloakCommunicationException("Impossible de réinitialiser le mot de passe", e);
        }
    }

    /**
     * Déclenche l'envoi d'un e-mail de réinitialisation de mot de passe.
     */
    @Async
    public void sendForgotPasswordEmail(String email) {
        try {
            List<UserRepresentation> users = keycloak.realm(properties.realm())
                    .users()
                    .search(null, null, null, email, 0, 1, null, true);

            if (users.isEmpty()) {
                log.warn("Reset password demandé pour email inconnu : {}", email);
                return;
            }

            String userId = users.get(0).getId();

            keycloak.realm(properties.realm())
                    .users()
                    .get(userId)
                    .executeActionsEmail(List.of("UPDATE_PASSWORD"));

            log.info("Email de réinitialisation envoyé à : {}", email);
        } catch (Exception e) {
            log.error("Erreur lors de l'envoi du reset password à {} : {}", email, e.getMessage());
            throw new KeycloakCommunicationException("Impossible d'envoyer l'email de récupération", e);
        }
    }

    private KeycloakCommunicationException translateException(String operation, RestClientException e) {
        log.error("Keycloak operation '{}' failed: {}", operation, e.getMessage());
        return new KeycloakCommunicationException(
                "Keycloak operation '%s' failed: %s".formatted(operation, e.getMessage()), e);
    }
}
