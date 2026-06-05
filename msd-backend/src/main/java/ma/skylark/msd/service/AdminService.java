package ma.skylark.msd.service;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import ma.skylark.msd.controller.dto.AdminStatsResponse;
import ma.skylark.msd.controller.dto.ProfessionalDocumentResponse;
import ma.skylark.msd.controller.dto.ProfessionalReviewResponse;
import ma.skylark.msd.controller.dto.SosRequestResponse;
import ma.skylark.msd.controller.dto.UserProfileResponse;
import ma.skylark.msd.domain.entity.PatientMedicalRecord;
import ma.skylark.msd.domain.entity.ProfessionalDocument;
import ma.skylark.msd.domain.entity.ProfessionalInfo;
import ma.skylark.msd.domain.entity.UserProfile;
import ma.skylark.msd.domain.entity.SosRequest;
import ma.skylark.msd.domain.model.ValidationStatus;
import ma.skylark.msd.repository.ProfessionalDocumentRepository;
import ma.skylark.msd.repository.ProfessionalInfoRepository;
import ma.skylark.msd.repository.SosRequestRepository;
import ma.skylark.msd.repository.UserProfileRepository;
import ma.skylark.msd.repository.ReviewRepository;
import ma.skylark.msd.repository.PatientMedicalRecordRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final ProfessionalInfoRepository professionalInfoRepository;
    private final ProfessionalDocumentRepository professionalDocumentRepository;
    private final UserProfileRepository userProfileRepository;
    private final SosRequestRepository sosRequestRepository;
    private final ReviewRepository reviewRepository;
    private final PatientMedicalRecordRepository patientMedicalRecordRepository;

    @Transactional(readOnly = true)
    public AdminStatsResponse getStats() {
        long totalProfessionals = professionalInfoRepository.countByStatusValidation(ValidationStatus.VALIDATED);
        
        long totalPatients = userProfileRepository.findAll().stream()
                .filter(u -> u.getProfessionalInfo() == null)
                .filter(this::isNotAdmin)
                .count();

        long pendingValidations = professionalInfoRepository.countByStatusValidation(ValidationStatus.PENDING);
        
        long totalSosRequests = sosRequestRepository.count();
        
        long completedMissions = professionalInfoRepository.findAll().stream()
                .mapToLong(pro -> pro.getCompletedMissionsCount() != null ? pro.getCompletedMissionsCount() : 0)
                .sum();

        Map<String, Long> requestsByService = sosRequestRepository.findAll().stream()
                .collect(Collectors.groupingBy(req -> req.getServiceType(), Collectors.counting()));

        Map<String, Long> professionalsByStatus = professionalInfoRepository.findAll().stream()
                .collect(Collectors.groupingBy(pro -> pro.getStatusValidation().name(), Collectors.counting()));

        return new AdminStatsResponse(
                totalPatients,
                totalProfessionals,
                pendingValidations,
                totalSosRequests,
                completedMissions,
                requestsByService,
                professionalsByStatus
        );
    }

    private boolean isNotAdmin(UserProfile user) {
        if (user.getEmail() != null && user.getEmail().toLowerCase().contains("admin")) return false;
        if (user.getFirstName() != null && user.getFirstName().toLowerCase().contains("admin")) return false;
        return true;
    }

    @Transactional(readOnly = true)
    public List<ProfessionalReviewResponse> getAllProfessionals() {
        return professionalInfoRepository.findAll().stream()
                .map(this::mapToReviewResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<UserProfileResponse> getAllPatients() {
        return userProfileRepository.findAll().stream()
                .filter(u -> u.getProfessionalInfo() == null)
                .filter(this::isNotAdmin)
                .map(u -> {
                    List<PatientMedicalRecord> records = patientMedicalRecordRepository.findByPatientId(u.getId());
                    return UserProfileResponse.from(u, records);
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<SosRequestResponse> getAllRequests() {
        return sosRequestRepository.findAll().stream()
                .sorted(Comparator.comparing(SosRequest::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder())))
                .map(req -> {
                    UserProfile patient = userProfileRepository.findById(req.getPatientId()).orElse(null);
                    UserProfile pro = req.getProfessionalId() != null ? userProfileRepository.findById(req.getProfessionalId()).orElse(null) : null;
                    boolean isRated = reviewRepository.findBySosRequestId(req.getId()).isPresent();
                    Integer rating = reviewRepository.findBySosRequestId(req.getId()).map(r -> r.getRating()).orElse(null);
                    return SosRequestResponse.fromEntity(req, patient, pro, isRated, rating);
                })
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ProfessionalReviewResponse> getProfessionalsByStatus(ValidationStatus status) {
        return professionalInfoRepository.findAll().stream()
                .filter(pro -> pro.getStatusValidation() == status)
                .map(this::mapToReviewResponse)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public ProfessionalReviewResponse getProfessionalDetails(Long id) {
        ProfessionalInfo pro = professionalInfoRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Professional not found"));
        return mapToReviewResponse(pro);
    }

    private ProfessionalReviewResponse mapToReviewResponse(ProfessionalInfo pro) {
        List<ProfessionalDocument> docs = professionalDocumentRepository.findByProfessionalInfoId(pro.getId());
        List<ProfessionalDocumentResponse> docResponses = docs.stream()
                .map(ProfessionalDocumentResponse::fromEntity)
                .collect(Collectors.toList());

        return new ProfessionalReviewResponse(
                pro.getId(),
                pro.getUser().getFirstName(),
                pro.getUser().getLastName(),
                pro.getUser().getEmail(),
                pro.getServiceType(),
                pro.getSpecialty(),
                pro.getAmbulanceType(),
                pro.getStatusValidation(),
                docResponses
        );
    }

    @Transactional
    public void updateProfessionalStatus(Long professionalInfoId, ValidationStatus status, String rejectionReason) {
        ProfessionalInfo pro = professionalInfoRepository.findById(professionalInfoId)
                .orElseThrow(() -> new EntityNotFoundException("Professional not found"));

        pro.setStatusValidation(status);
        if (status == ValidationStatus.REJECTED) {
            pro.setRejectionReason(rejectionReason);
        } else {
            pro.setRejectionReason(null);
        }
        professionalInfoRepository.save(pro);
    }
}
