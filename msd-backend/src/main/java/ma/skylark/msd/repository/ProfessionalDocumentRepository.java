package ma.skylark.msd.repository;

import ma.skylark.msd.domain.entity.ProfessionalDocument;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProfessionalDocumentRepository extends JpaRepository<ProfessionalDocument, Long> {
    List<ProfessionalDocument> findByProfessionalInfoId(Long professionalInfoId);
}
