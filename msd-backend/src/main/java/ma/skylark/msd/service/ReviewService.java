package ma.skylark.msd.service;

import lombok.RequiredArgsConstructor;
import ma.skylark.msd.controller.dto.CreateReviewRequest;
import ma.skylark.msd.controller.dto.ReviewResponse;
import ma.skylark.msd.domain.entity.ProfessionalInfo;
import ma.skylark.msd.domain.entity.Review;
import ma.skylark.msd.domain.entity.SosRequest;
import ma.skylark.msd.domain.entity.UserProfile;
import ma.skylark.msd.domain.exception.SosRequestException;
import ma.skylark.msd.repository.ProfessionalInfoRepository;
import ma.skylark.msd.repository.ReviewRepository;
import ma.skylark.msd.repository.SosRequestRepository;
import ma.skylark.msd.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepository;
    private final SosRequestRepository sosRequestRepository;
    private final ProfessionalInfoRepository professionalInfoRepository;
    private final UserProfileRepository userProfileRepository;

    @Transactional
    public void submitReview(CreateReviewRequest request, String keycloakUserId) {
        UserProfile patient = userProfileRepository.findByKeycloakId(keycloakUserId)
                .orElseThrow(() -> new IllegalArgumentException("Patient non trouvé"));

        SosRequest sosRequest = sosRequestRepository.findById(request.sosRequestId())
                .orElseThrow(() -> new SosRequestException("Demande SOS non trouvée"));

        // Validations
        if (!sosRequest.getPatientId().equals(patient.getId())) {
            throw new SosRequestException("Vous n'êtes pas autorisé à évaluer cette demande");
        }

        if (!"completed".equalsIgnoreCase(sosRequest.getStatus())) {
            throw new SosRequestException("Vous ne pouvez évaluer qu'une demande terminée");
        }

        if (sosRequest.getProfessionalId() == null) {
            throw new SosRequestException("Aucun professionnel n'est associé à cette demande");
        }

        if (reviewRepository.findBySosRequestId(request.sosRequestId()).isPresent()) {
            throw new SosRequestException("Cette demande a déjà été évaluée");
        }

        // Créer l'avis
        Review review = Review.builder()
                .sosRequest(sosRequest)
                .patientId(patient.getId())
                .professionalId(sosRequest.getProfessionalId())
                .rating(request.rating())
                .comment(request.comment())
                .build();

        reviewRepository.save(review);

        // Mettre à jour la moyenne du professionnel
        ProfessionalInfo proInfo = professionalInfoRepository.findByUserId(sosRequest.getProfessionalId())
                .orElseThrow(() -> new SosRequestException("Profil professionnel non trouvé"));

        proInfo.updateRating(request.rating());
        professionalInfoRepository.save(proInfo);
    }

    @Transactional(readOnly = true)
    public List<ReviewResponse> getProfessionalReviews(Long professionalId) {
        return reviewRepository.findByProfessionalId(professionalId).stream()
                .map(r -> {
                    UserProfile patient = userProfileRepository.findById(r.getPatientId()).orElse(null);
                    return new ReviewResponse(
                            r.getId(),
                            patient != null ? patient.getFirstName() : "Patient",
                            patient != null ? patient.getLastName() : "Anonyme",
                            r.getRating(),
                            r.getComment(),
                            r.getCreatedAt()
                    );
                })
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ReviewResponse> getMyReviews(String keycloakUserId) {
        UserProfile profile = userProfileRepository.findByKeycloakId(keycloakUserId)
                .orElseThrow(() -> new IllegalArgumentException("Utilisateur non trouvé"));
        return getProfessionalReviews(profile.getId());
    }
}
