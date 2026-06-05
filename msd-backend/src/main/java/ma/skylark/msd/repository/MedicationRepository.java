package ma.skylark.msd.repository;

import ma.skylark.msd.domain.entity.Medication;import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.UUID;
import java.util.Optional; 

public interface MedicationRepository extends JpaRepository<Medication, UUID> {
    /**
     * Finds medications and fetches intakeTimes in a single query to avoid N+1.
     */
    @EntityGraph(attributePaths = {"intakeTimes"})
    List<Medication> findByUserId(String userId);

    Optional<Medication> findByIdAndUserId(UUID id, String userId);
}