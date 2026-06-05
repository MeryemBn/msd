package ma.skylark.msd.service;

import ma.skylark.msd.controller.dto.UpdateProfileRequest;
import ma.skylark.msd.controller.dto.UserProfileResponse;
import ma.skylark.msd.domain.entity.UserProfile;
import ma.skylark.msd.domain.entity.PatientMedicalRecord;
import ma.skylark.msd.domain.entity.ProfessionalDocument;
import ma.skylark.msd.domain.entity.ProfessionalInfo;
import ma.skylark.msd.domain.exception.ProfileNotFoundException;
import ma.skylark.msd.repository.UserProfileRepository;
import ma.skylark.msd.repository.PatientMedicalRecordRepository;
import ma.skylark.msd.repository.ProfessionalDocumentRepository;
import ma.skylark.msd.repository.ProfessionalInfoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserProfileService {

    private final UserProfileRepository userProfileRepository;
    private final PatientMedicalRecordRepository medicalRecordRepository;
    private final ProfessionalDocumentRepository documentRepository;
    private final ProfessionalInfoRepository professionalInfoRepository;

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Transactional(readOnly = true)
    public UserProfileResponse getProfile(String keycloakId) {
        var profile = findByKeycloakIdOrThrow(keycloakId);
        var medicalRecords = medicalRecordRepository.findByPatientId(profile.getId());
        return UserProfileResponse.from(profile, medicalRecords);
    }

    @Transactional
    public UserProfileResponse createProfile(String keycloakId, String firstName, String lastName, String email) {
        var profile = new UserProfile(keycloakId);
        profile.setInitialDetails(firstName, lastName, email);
        var saved = userProfileRepository.save(profile);
        log.info("Created profile for keycloakId '{}'", keycloakId);
        return UserProfileResponse.from(saved, List.of());
    }

    @Transactional
    public UserProfileResponse updateProfile(String keycloakId, UpdateProfileRequest request) {
        var profile = findByKeycloakIdOrThrow(keycloakId);
        profile.updatePersonalInfo(request.firstName(), request.lastName(), request.phoneNumber());
        profile.updateAddress(request.address(), request.city());
        profile.updateProFields(request.serviceType(), request.specialty(), request.ambulanceType());

        checkAndMarkIfComplete(profile);

        var saved = userProfileRepository.save(profile);
        var medicalRecords = medicalRecordRepository.findByPatientId(saved.getId());
        return UserProfileResponse.from(saved, medicalRecords);
    }

    @Transactional
    public void markProfileAsComplete(String keycloakId) {
        var profile = findByKeycloakIdOrThrow(keycloakId);
        profile.setProfileComplete(true);
        userProfileRepository.save(profile);
    }

    private void checkAndMarkIfComplete(UserProfile profile) {
        boolean hasBasicInfo = isNotEmpty(profile.getPhoneNumber())
                && isNotEmpty(profile.getCity())
                && isNotEmpty(profile.getAddress());

        if (!hasBasicInfo) {
            profile.setProfileComplete(false);
            return;
        }

        if (profile.getProfessionalInfo() != null) {
            if (!isNotEmpty(profile.getProfessionalInfo().getServiceType())) {
                profile.setProfileComplete(false);
                return;
            }
            List<ProfessionalDocument> docs = documentRepository.findByProfessionalInfoId(profile.getProfessionalInfo().getId());
            profile.setProfileComplete(!docs.isEmpty());
        } else {
            List<PatientMedicalRecord> records = medicalRecordRepository.findByPatientId(profile.getId());
            profile.setProfileComplete(!records.isEmpty());
        }
    }

    private boolean isNotEmpty(String str) {
        return str != null && !str.isBlank();
    }

    @Transactional
    public void uploadProfessionalDocument(String keycloakId, String type, String ocrResult, MultipartFile file) throws IOException {
        var profile = findByKeycloakIdOrThrow(keycloakId);
        ProfessionalInfo proInfo = profile.getProfessionalInfo();
        if (proInfo == null) throw new IllegalStateException("User is not a professional");

        // Structure : uploads/documents/pro_{id}_{nom}/...
        String folderName = profile.getId() + "_" + profile.getLastName().replaceAll("[^a-zA-Z0-9]", "");
        Path userDocDir = Paths.get(uploadDir, "documents", folderName);

        if (!Files.exists(userDocDir)) {
            Files.createDirectories(userDocDir);
        }

        String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
        Path target = userDocDir.resolve(fileName);
        Files.write(target, file.getBytes());

        ProfessionalDocument doc = ProfessionalDocument.builder()
                .professionalInfo(proInfo)
                .documentType(type)
                .filePath("documents/" + folderName + "/" + fileName) // Chemin relatif à 'uploads/'
                .fileName(file.getOriginalFilename())
                .ocrResult(ocrResult)
                .build();

        documentRepository.save(doc);
        checkAndMarkIfComplete(profile);
        userProfileRepository.save(profile);
    }

    @Transactional
    public PatientMedicalRecord addMedicalRecord(String keycloakId, PatientMedicalRecord record) {
        var profile = findByKeycloakIdOrThrow(keycloakId);
        record.setPatientId(profile.getId());
        var saved = medicalRecordRepository.save(record);
        checkAndMarkIfComplete(profile);
        userProfileRepository.save(profile);
        return saved;
    }

    @Transactional
    public void deleteMedicalRecord(String keycloakId, Long recordId) {
        var profile = findByKeycloakIdOrThrow(keycloakId);
        medicalRecordRepository.findById(recordId).ifPresent(record -> {
            if (record.getPatientId().equals(profile.getId())) {
                medicalRecordRepository.delete(record);
                checkAndMarkIfComplete(profile);
                userProfileRepository.save(profile);
            }
        });
    }

    private UserProfile findByKeycloakIdOrThrow(String keycloakId) {
        return userProfileRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new ProfileNotFoundException("Profile not found for user: " + keycloakId));
    }
}
