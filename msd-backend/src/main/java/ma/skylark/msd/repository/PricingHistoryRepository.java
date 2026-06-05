package ma.skylark.msd.repository;

import ma.skylark.msd.domain.entity.PricingHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PricingHistoryRepository extends JpaRepository<PricingHistory, Long> {
    List<PricingHistory> findByProfessionalId(Long professionalId);
}
