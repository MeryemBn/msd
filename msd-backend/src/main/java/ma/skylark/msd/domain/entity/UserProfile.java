package ma.skylark.msd.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.Objects;

/**
 * Represents a user's profile in the system.
 * Linked to a Keycloak user via {@code keycloakId} (the JWT {@code sub} claim).
 * <p>
 * Business key: {@code keycloakId} — used for equals/hashCode.
 */
@Entity
@Table(name = "user_profiles")
@Getter
@Setter
@NoArgsConstructor(access = lombok.AccessLevel.PROTECTED)
public class UserProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", updatable = false)
    private Long id;

    @Column(name = "keycloak_id", nullable = false, unique = true, updatable = false, length = 255)
    private String keycloakId;

    @Column(name = "first_name", length = 100)
    private String firstName;

    @Column(name = "last_name", length = 100)
    private String lastName;

    @Column(name = "email", length = 255)
    private String email;

    @Column(name = "phone_number", length = 20)
    private String phoneNumber;

    @Column(name = "address", length = 500)
    private String address;

    @Column(name = "city", length = 100)
    private String city;

    @Column(name = "is_profile_complete", nullable = false)
    private boolean isProfileComplete = false;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private ProfessionalInfo professionalInfo;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    /**
     * Creates a new profile linked to a Keycloak user.
     *
     * @param keycloakId the Keycloak user ID (JWT sub claim)
     */
    public UserProfile(String keycloakId) {
        this.keycloakId = Objects.requireNonNull(keycloakId, "keycloakId must not be null");
    }

    // --- Intent-revealing mutators ---

    /**
     * Sets the initial details provided during signup.
     */
    public void setInitialDetails(String firstName, String lastName, String email) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
    }

    /**
     * Updates personal information fields.
     */
    public void updatePersonalInfo(String firstName, String lastName, String phoneNumber) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.phoneNumber = phoneNumber;
    }

    /**
     * Updates address fields.
     */
    public void updateAddress(String address, String city) {
        this.address = address;
        this.city = city;
    }

    /**
     * Updates pro-only fields. Only updates if values are provided.
     */
    public void updateProFields(String serviceType, String specialty, String ambulanceType) {
        if (serviceType == null && specialty == null && ambulanceType == null) {
            return;
        }
        
        if (this.professionalInfo == null) {
            this.professionalInfo = new ProfessionalInfo();
            this.professionalInfo.setUser(this);
        }
        
        if (serviceType != null && !serviceType.isBlank()) {
            this.professionalInfo.setServiceType(serviceType);
        }
        if (specialty != null && !specialty.isBlank()) {
            this.professionalInfo.setSpecialty(specialty);
        }
        if (ambulanceType != null && !ambulanceType.isBlank()) {
            this.professionalInfo.setAmbulanceType(ambulanceType);
        }
    }

    // --- Identity (business key: keycloakId) — manual, not Lombok ---

    @Override
    public boolean equals(Object o) {
        if (this == o)
            return true;
        if (!(o instanceof UserProfile that))
            return false;
        return keycloakId.equals(that.keycloakId);
    }

    @Override
    public int hashCode() {
        return keycloakId.hashCode();
    }

    @Override
    public String toString() {
        return "UserProfile{keycloakId='%s', firstName='%s', lastName='%s'}"
                .formatted(keycloakId, firstName, lastName);
    }
}
