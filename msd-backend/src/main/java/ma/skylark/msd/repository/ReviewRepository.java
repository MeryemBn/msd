package ma.skylark.msd.repository;

import ma.skylark.msd.domain.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    Optional<Review> findBySosRequestId(UUID sosRequestId);
    List<Review> findByProfessionalId(Long professionalId);
}
