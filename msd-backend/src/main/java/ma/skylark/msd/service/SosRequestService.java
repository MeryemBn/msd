package ma.skylark.msd.service;

import lombok.RequiredArgsConstructor;
import ma.skylark.msd.controller.dto.CreateSosRequest;
import ma.skylark.msd.controller.dto.SosRequestResponse;
import ma.skylark.msd.domain.entity.LocationDetails;
import ma.skylark.msd.domain.entity.ProfessionalInfo;
import ma.skylark.msd.domain.entity.RequestStatusHistory;
import ma.skylark.msd.domain.entity.Review;
import ma.skylark.msd.domain.entity.SosRequest;
import ma.skylark.msd.domain.entity.UserProfile;
import ma.skylark.msd.domain.exception.SosRequestException;
import ma.skylark.msd.domain.model.InterventionMode;
import ma.skylark.msd.domain.model.RequestStatus;
import ma.skylark.msd.domain.model.ServiceType;
import ma.skylark.msd.repository.ProfessionalInfoRepository;
import ma.skylark.msd.repository.ReviewRepository;
import ma.skylark.msd.repository.SosRequestRepository;
import ma.skylark.msd.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;

/**
 * Service for creating and validating SOS requests.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SosRequestService {

    private final SosRequestRepository sosRequestRepository;
    private final UserProfileRepository userProfileRepository;
    private final ReviewRepository reviewRepository;
    private final ProfessionalInfoRepository professionalInfoRepository;
    private final PricingService pricingService;

    @Transactional
    public SosRequestResponse createRequest(CreateSosRequest request, String keycloakUserId) {
        UserProfile patientProfile = userProfileRepository.findByKeycloakId(keycloakUserId)
                .orElseGet(() -> userProfileRepository.save(new UserProfile(keycloakUserId)));
        Long patientId = patientProfile.getId();

        validateBusinessRules(request);

        BigDecimal finalPrice = null;

        // Normalisation des chaînes pour correspondre aux tarifs (Utilisation du format avec underscores)
        String serviceTypeStr = request.serviceType().name().toUpperCase();
        String specialtyStr = request.specialty() != null ? normalizeEnumName(request.specialty().name()) : null;
        String ambulanceTypeStr = request.ambulanceType() != null ? normalizeEnumName(request.ambulanceType().name()) : null;
        String modeStr = request.interventionMode().name().toUpperCase();

        if (request.professionalId() != null) {
            if (!userProfileRepository.existsById(request.professionalId())) {
                throw new SosRequestException("Le professionnel sélectionné n'existe pas");
            }

            if (request.interventionMode() == InterventionMode.APPOINTMENT) {
                boolean hasOngoingAppointment = sosRequestRepository.existsOngoingAppointmentByPatientAndProfessional(
                        patientId, request.professionalId());
                if (hasOngoingAppointment) {
                    throw new SosRequestException("Vous avez déjà un rendez-vous en cours avec ce professionnel.");
                }

                if (request.appointmentDatetime() != null) {
                    boolean hasTimeConflict = sosRequestRepository.existsByProfessionalIdAndAppointmentDatetime(
                            request.professionalId(),
                            request.appointmentDatetime());
                    if (hasTimeConflict) {
                        throw new SosRequestException("Ce créneau horaire est déjà pris.");
                    }
                }
            }

            Double distance = null;
            if (request.location() != null) {
                ProfessionalInfo pro = professionalInfoRepository.findByUserId(request.professionalId()).orElse(null);
                if (pro != null && pro.getLatitude() != null && pro.getLongitude() != null) {
                    distance = calculateDistance(pro.getLatitude(), pro.getLongitude(), 
                            request.location().latitude(), request.location().longitude());
                }
            }

            finalPrice = pricingService.calculateFinalPrice(
                    request.professionalId(),
                    serviceTypeStr,
                    specialtyStr,
                    ambulanceTypeStr,
                    modeStr,
                    distance
            );
        }

        SosRequest entity = SosRequest.builder()
                .id(UUID.randomUUID())
                .patientId(patientId)
                .professionalId(request.professionalId())
                .serviceType(serviceTypeStr)
                .ambulanceType(ambulanceTypeStr)
                .specialty(specialtyStr)
                .interventionMode(modeStr)
                .appointmentDatetime(request.appointmentDatetime())
                .paymentMethod(request.paymentMethod().name().toUpperCase())
                .price(finalPrice != null ? finalPrice : request.price())
                .status(RequestStatus.PENDING.name().toLowerCase(Locale.ROOT)) 
                .build();

        if (request.location() != null) {
            LocationDetails location = LocationDetails.builder()
                    .id(UUID.randomUUID())
                    .sosRequest(entity)
                    .address(request.location().address().trim())
                    .latitude(request.location().latitude())
                    .longitude(request.location().longitude())
                    .build();
            entity.setLocation(location);
        }

        RequestStatusHistory initialHistory = RequestStatusHistory.builder()
                .id(UUID.randomUUID())
                .sosRequest(entity)
                .changedBy(patientId)
                .status(RequestStatus.PENDING.name().toLowerCase(Locale.ROOT))
                .reason(request.professionalId() != null ? "Direct" : "Urgence")
                .build();
        entity.getStatusHistory().add(initialHistory);

        SosRequest saved = sosRequestRepository.save(entity);
        UserProfile professionalProfile = request.professionalId() != null ? userProfileRepository.findById(request.professionalId()).orElse(null) : null;

        return SosRequestResponse.fromEntity(saved, patientProfile, professionalProfile, false, null);
    }

    private String normalizeEnumName(String name) {
        if (name == null) return null;
        // Transforme camelCase ou PascalCase en SNAKE_CASE si nécessaire, mais ici on gère surtout les noms d'enums standards
        return name.replaceAll("([a-z])([A-Z])", "$1_$2").toUpperCase();
    }

    @Transactional
    public SosRequestResponse updateStatus(UUID requestId, RequestStatus newStatus, String keycloakUserId) {
        UserProfile profile = userProfileRepository.findByKeycloakId(keycloakUserId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        SosRequest request = sosRequestRepository.findById(requestId)
                .orElseThrow(() -> new SosRequestException("SOS request not found"));

        boolean isPatient = request.getPatientId().equals(profile.getId());
        boolean isProfessional = profile.getId().equals(request.getProfessionalId());

        if (!isPatient && !isProfessional) {
            throw new SosRequestException("Forbidden");
        }

        String oldStatus = request.getStatus();
        request.setStatus(newStatus.name().toLowerCase(Locale.ROOT));

        if (newStatus == RequestStatus.COMPLETED && !"completed".equals(oldStatus) && request.getProfessionalId() != null) {
            professionalInfoRepository.incrementCompletedMissionsCount(request.getProfessionalId());
        }

        RequestStatusHistory history = RequestStatusHistory.builder()
                .id(UUID.randomUUID())
                .sosRequest(request)
                .changedBy(profile.getId())
                .status(newStatus.name().toLowerCase(Locale.ROOT))
                .reason("Status updated")
                .build();
        request.getStatusHistory().add(history);

        SosRequest saved = sosRequestRepository.save(request);
        UserProfile patient = userProfileRepository.findById(saved.getPatientId()).orElse(null);
        UserProfile professional = saved.getProfessionalId() != null ? userProfileRepository.findById(saved.getProfessionalId()).orElse(null) : null;
        
        Optional<Review> reviewOpt = reviewRepository.findBySosRequestId(saved.getId());
        return SosRequestResponse.fromEntity(saved, patient, professional, reviewOpt.isPresent(), reviewOpt.map(Review::getRating).orElse(null));
    }

    public List<SosRequestResponse> getMyRequests(String keycloakUserId) {
        UserProfile profile = userProfileRepository.findByKeycloakId(keycloakUserId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        return sosRequestRepository.findByPatientId(profile.getId()).stream()
                .map(req -> {
                    UserProfile professional = req.getProfessionalId() != null ? userProfileRepository.findById(req.getProfessionalId()).orElse(null) : null;
                    Optional<Review> reviewOpt = reviewRepository.findBySosRequestId(req.getId());
                    return SosRequestResponse.fromEntity(req, profile, professional, reviewOpt.isPresent(), reviewOpt.map(Review::getRating).orElse(null));
                })
                .toList();
    }

    private void validateBusinessRules(CreateSosRequest request) {
        if (ServiceType.AMBULANCE == request.serviceType() && request.ambulanceType() == null) {
            throw new IllegalArgumentException("ambulanceType is required");
        }
        if ((ServiceType.TELECONSULTATION == request.serviceType() || ServiceType.DOCTOR == request.serviceType()) && request.specialty() == null) {
            throw new IllegalArgumentException("specialty is required");
        }
        if (InterventionMode.APPOINTMENT == request.interventionMode() && request.appointmentDatetime() == null) {
            throw new IllegalArgumentException("appointmentDatetime is required");
        }
    }

    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        double earthRadius = 6371;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return earthRadius * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }
}
