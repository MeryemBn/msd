package ma.skylark.msd.repository;

import ma.skylark.msd.domain.entity.UserProfile;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

/**
 * Data access for UserProfile entities.
 */
public interface UserProfileRepository extends JpaRepository<UserProfile, Long> {

    Optional<UserProfile> findByKeycloakId(String keycloakId);

    boolean existsByKeycloakId(String keycloakId);
}
