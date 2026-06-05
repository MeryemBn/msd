package ma.skylark.msd.service;

import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import ma.skylark.msd.controller.dto.ProfessionalStatusResponse;
import ma.skylark.msd.controller.dto.RevenueStatsDTO;
import ma.skylark.msd.controller.dto.SosRequestResponse;
import ma.skylark.msd.controller.dto.UserProfileResponse;
import ma.skylark.msd.domain.entity.ProfessionalInfo;
import ma.skylark.msd.domain.entity.RequestStatusHistory;
import ma.skylark.msd.domain.entity.Review;
import ma.skylark.msd.domain.entity.SosRequest;
import ma.skylark.msd.domain.entity.UserProfile;
import ma.skylark.msd.domain.model.RequestStatus;
import ma.skylark.msd.domain.model.ValidationStatus;
import ma.skylark.msd.repository.ProfessionalDocumentRepository;
import ma.skylark.msd.repository.ProfessionalInfoRepository;
import ma.skylark.msd.repository.ReviewRepository;
import ma.skylark.msd.repository.SosRequestRepository;
import ma.skylark.msd.repository.UserProfileRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ProfessionalService {

    private final UserProfileRepository userProfileRepository;
    private final ProfessionalInfoRepository professionalInfoRepository;
    private final SosRequestRepository sosRequestRepository;
    private final ProfessionalDocumentRepository professionalDocumentRepository;
    private final ReviewRepository reviewRepository;
    private final PricingService pricingService;

    @Transactional(readOnly = true)
    public ProfessionalStatusResponse getProfessionalStatus(String keycloakId) {
        UserProfile profile = userProfileRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        ProfessionalInfo pro = professionalInfoRepository.findByUserId(profile.getId())
                .orElseThrow(() -> new EntityNotFoundException("Professional profile not found"));

        boolean hasDocs = !professionalDocumentRepository.findByProfessionalInfoId(pro.getId()).isEmpty();

        return new ProfessionalStatusResponse(
                pro.getStatusValidation(),
                pro.getServiceType() != null,
                hasDocs,
                pro.getServiceType(),
                pro.getSpecialty() != null ? pro.getSpecialty() : pro.getAmbulanceType(),
                Boolean.TRUE.equals(pro.getIsAvailable()),
                pro.getAverageRating(),
                pro.getTotalReviews(),
                pro.getCompletedMissionsCount()
        );
    }

    @Transactional
    public void updateAvailability(String keycloakId, boolean available) {
        UserProfile profile = userProfileRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        ProfessionalInfo pro = professionalInfoRepository.findByUserId(profile.getId())
                .orElseThrow(() -> new EntityNotFoundException("Professional profile not found"));

        pro.setIsAvailable(available);
        professionalInfoRepository.save(pro);
    }

    @Transactional
    public void updateLocation(String keycloakId, Double latitude, Double longitude) {
        UserProfile profile = userProfileRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        ProfessionalInfo pro = professionalInfoRepository.findByUserId(profile.getId())
                .orElseThrow(() -> new EntityNotFoundException("Professional profile not found"));

        pro.setLatitude(latitude);
        pro.setLongitude(longitude);
        professionalInfoRepository.save(pro);
    }

    @Transactional(readOnly = true)
    public List<UserProfileResponse> searchProfessionals(
            String serviceType,
            String specialty,
            String ambulanceType,
            Double latitude,
            Double longitude,
            Double maxDistanceKm) {

        String st = (serviceType != null) ? serviceType.toLowerCase() : "";
        String spec = (specialty != null) ? specialty.toLowerCase() : null;
        String amb = (ambulanceType != null) ? ambulanceType.toLowerCase() : null;

        List<ProfessionalInfo> pros = professionalInfoRepository.findEligibleProfessionals(st, spec, amb);

        return pros.stream()
                .map(pro -> {
                    Double dist = null;
                    if (latitude != null && longitude != null && pro.getLatitude() != null && pro.getLongitude() != null) {
                        dist = calculateDistance(latitude, longitude, pro.getLatitude(), pro.getLongitude());
                    }
                    return UserProfileResponse.from(pro.getUser(), List.of(), dist);
                })
                .filter(resp -> {
                    if (latitude == null || longitude == null) return true;
                    if (resp.distance() == null) return false;
                    return maxDistanceKm == null || resp.distance() <= maxDistanceKm;
                })
                .toList();
    }

    @Transactional(readOnly = true)
    public List<SosRequestResponse> getPendingAppointments(String keycloakId) {
        UserProfile profile = userProfileRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        return sosRequestRepository.findByProfessionalIdAndStatusIgnoreCase(profile.getId(), "pending").stream()
                .map(req -> {
                    UserProfile patient = userProfileRepository.findById(req.getPatientId()).orElse(null);
                    return SosRequestResponse.fromEntity(req, patient, profile);
                })
                .toList();
    }

    @Transactional
    public SosRequestResponse acceptRequest(UUID requestId, String keycloakId) {
        UserProfile proProfile = userProfileRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        ProfessionalInfo proInfo = professionalInfoRepository.findByUserId(proProfile.getId())
                .orElseThrow(() -> new EntityNotFoundException("Professional info not found"));

        if (proInfo.getStatusValidation() != ValidationStatus.VALIDATED) {
            throw new IllegalStateException("Your account must be validated to accept requests");
        }

        SosRequest request = sosRequestRepository.findById(requestId)
                .orElseThrow(() -> new EntityNotFoundException("Request not found"));

        if (request.getProfessionalId() != null && !request.getProfessionalId().equals(proProfile.getId())) {
            throw new IllegalStateException("Request already accepted by another professional");
        }

        // Si déjà confirmé par moi-même, on retourne l'état actuel
        if (proProfile.getId().equals(request.getProfessionalId()) && 
            ("confirmed".equalsIgnoreCase(request.getStatus()) || "awaiting_payment".equalsIgnoreCase(request.getStatus()))) {
            UserProfile patientProfile = userProfileRepository.findById(request.getPatientId()).orElse(null);
            return SosRequestResponse.fromEntity(request, patientProfile, proProfile);
        }

        request.setProfessionalId(proProfile.getId());
        
        // Logique de paiement : si par carte, on attend le paiement
        if ("BANK_CARD".equalsIgnoreCase(request.getPaymentMethod())) {
            request.setStatus("awaiting_payment");
        } else {
            request.setStatus("confirmed");
        }

        Double distance = null;
        if (proInfo.getLatitude() != null && proInfo.getLongitude() != null && request.getLocation() != null) {
            distance = calculateDistance(proInfo.getLatitude(), proInfo.getLongitude(),
                    request.getLocation().getLatitude(), request.getLocation().getLongitude());
        }

        BigDecimal finalPrice = pricingService.calculateFinalPrice(
                proProfile.getId(),
                request.getServiceType(),
                request.getSpecialty(),
                request.getAmbulanceType(),
                request.getInterventionMode(),
                distance
        );
        request.setPrice(finalPrice);

        SosRequest saved = sosRequestRepository.save(request);
        UserProfile patientProfile = userProfileRepository.findById(saved.getPatientId()).orElse(null);

        return SosRequestResponse.fromEntity(saved, patientProfile, proProfile);
    }

    @Transactional
    public SosRequestResponse rejectRequest(UUID requestId, String keycloakId) {
        UserProfile proProfile = userProfileRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        SosRequest request = sosRequestRepository.findById(requestId)
                .orElseThrow(() -> new EntityNotFoundException("Request not found"));

        if (request.getProfessionalId() != null && !request.getProfessionalId().equals(proProfile.getId())) {
            throw new IllegalStateException("You are not authorized to reject this request");
        }

        request.setStatus("rejected");

        RequestStatusHistory history = RequestStatusHistory.builder()
                .id(UUID.randomUUID())
                .sosRequest(request)
                .changedBy(proProfile.getId())
                .status("rejected")
                .reason("Rejected by professional")
                .build();
        request.getStatusHistory().add(history);

        SosRequest saved = sosRequestRepository.save(request);
        UserProfile patientProfile = userProfileRepository.findById(saved.getPatientId()).orElse(null);

        return SosRequestResponse.fromEntity(saved, patientProfile, proProfile);
    }

    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        double earthRadius = 6371;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadius * c;
    }

    @Transactional(readOnly = true)
    public Optional<SosRequestResponse> getActiveMission(String keycloakId) {
        UserProfile profile = userProfileRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        return sosRequestRepository.findActiveMissionByProfessional(profile.getId())
                .map(req -> {
                    UserProfile patient = userProfileRepository.findById(req.getPatientId()).orElse(null);
                    return SosRequestResponse.fromEntity(req, patient, profile);
                });
    }

    @Transactional(readOnly = true)
    public List<SosRequestResponse> getMissions(String keycloakId) {
        UserProfile profile = userProfileRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        return sosRequestRepository.findByProfessionalId(profile.getId()).stream()
                .map(req -> {
                    UserProfile patient = userProfileRepository.findById(req.getPatientId()).orElse(null);
                    Optional<Review> reviewOpt = reviewRepository.findBySosRequestId(req.getId());
                    boolean isRated = reviewOpt.isPresent();
                    Integer rating = reviewOpt.map(Review::getRating).orElse(null);
                    return SosRequestResponse.fromEntity(req, patient, profile, isRated, rating);
                })
                .toList();
    }

    @Transactional
    public SosRequestResponse updateRequestStatus(UUID requestId, RequestStatus status, String keycloakId) {
        UserProfile proProfile = userProfileRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        SosRequest request = sosRequestRepository.findById(requestId)
                .orElseThrow(() -> new EntityNotFoundException("Request not found"));

        if (!proProfile.getId().equals(request.getProfessionalId())) {
            throw new IllegalStateException("You are not the professional assigned to this request");
        }

        String oldStatus = request.getStatus();
        String statusValue = status.name().toLowerCase(Locale.ROOT);
        request.setStatus(statusValue);

        if (status == RequestStatus.COMPLETED && !"completed".equals(oldStatus)) {
            professionalInfoRepository.incrementCompletedMissionsCount(proProfile.getId());
        }

        RequestStatusHistory history = RequestStatusHistory.builder()
                .id(UUID.randomUUID())
                .sosRequest(request)
                .changedBy(proProfile.getId())
                .status(statusValue)
                .reason("Status updated by professional")
                .build();
        request.getStatusHistory().add(history);

        SosRequest saved = sosRequestRepository.save(request);
        UserProfile patientProfile = userProfileRepository.findById(saved.getPatientId()).orElse(null);

        return SosRequestResponse.fromEntity(saved, patientProfile, proProfile);
    }

    @Transactional(readOnly = true)
    public List<SosRequestResponse> getEligibleRequests(String keycloakId) {
        UserProfile profile = userProfileRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        ProfessionalInfo pro = professionalInfoRepository.findByUserId(profile.getId())
                .orElseThrow(() -> new EntityNotFoundException("Professional profile not found"));

        if (pro.getStatusValidation() != ValidationStatus.VALIDATED || !Boolean.TRUE.equals(pro.getIsAvailable())) {
            return Collections.emptyList();
        }

        String filterValue = "ambulance".equalsIgnoreCase(pro.getServiceType()) ? pro.getAmbulanceType() : pro.getSpecialty();

        return sosRequestRepository.findAvailableRequests(pro.getServiceType(), filterValue).stream()
                .filter(req -> isWithinRange(pro, req))
                .map(req -> {
                    UserProfile patient = userProfileRepository.findById(req.getPatientId()).orElse(null);
                    return SosRequestResponse.fromEntity(req, patient, profile);
                })
                .toList();
    }

    private boolean isWithinRange(ProfessionalInfo pro, SosRequest req) {
        if (pro.getLatitude() == null || pro.getLongitude() == null || req.getLocation() == null) {
            return false;
        }
        double dist = calculateDistance(pro.getLatitude(), pro.getLongitude(), req.getLocation().getLatitude(), req.getLocation().getLongitude());
        return dist <= 20.0;
    }

    @Transactional(readOnly = true)
    public List<LocalDateTime> getAvailableSlots(Long professionalId, String dateStr) {
        UserProfile professional = userProfileRepository.findById(professionalId)
                .orElseThrow(() -> new EntityNotFoundException("Professional not found"));

        LocalDate date = LocalDate.parse(dateStr, DateTimeFormatter.ISO_LOCAL_DATE);
        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.plusDays(1).atStartOfDay();

        List<LocalDateTime> bookedTimes = sosRequestRepository.findBookedTimesByProfessionalAndDate(
                professionalId, startOfDay, endOfDay);

        List<LocalDateTime> allSlots = generateTimeSlots(date);

        return allSlots.stream()
                .filter(slot -> !bookedTimes.contains(slot))
                .toList();
    }

    private List<LocalDateTime> generateTimeSlots(LocalDate date) {
        List<LocalDateTime> slots = new ArrayList<>();
        LocalTime startTime = LocalTime.of(8, 0);
        LocalTime endTime = LocalTime.of(18, 0);

        LocalTime currentTime = startTime;
        while (currentTime.isBefore(endTime)) {
            slots.add(LocalDateTime.of(date, currentTime));
            currentTime = currentTime.plusMinutes(30);
        }
        return slots;
    }

    @Transactional(readOnly = true)
    public RevenueStatsDTO getRevenueStats(String keycloakId) {
        UserProfile profile = userProfileRepository.findByKeycloakId(keycloakId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        List<SosRequest> completedMissions = sosRequestRepository.findCompletedMissionsByProfessional(profile.getId());

        BigDecimal totalRevenue = completedMissions.stream()
                .map(SosRequest::getPrice)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        LocalDate now = LocalDate.now();
        BigDecimal monthlyRevenue = completedMissions.stream()
                .filter(req -> req.getCreatedAt().getMonth() == now.getMonth() && req.getCreatedAt().getYear() == now.getYear())
                .map(SosRequest::getPrice)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Map<YearMonth, BigDecimal> revenueByMonthMap = completedMissions.stream()
                .filter(req -> req.getPrice() != null)
                .collect(Collectors.groupingBy(
                        req -> YearMonth.from(req.getCreatedAt()),
                        Collectors.reducing(BigDecimal.ZERO, SosRequest::getPrice, BigDecimal::add)
                ));

        List<RevenueStatsDTO.MonthlyRevenue> revenueByMonth = revenueByMonthMap.entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .map(entry -> new RevenueStatsDTO.MonthlyRevenue(
                        entry.getKey().getMonth().getDisplayName(TextStyle.SHORT, Locale.ENGLISH).toUpperCase(),
                        entry.getValue()))
                .collect(Collectors.toList());

        return RevenueStatsDTO.builder()
                .totalRevenue(totalRevenue)
                .monthlyRevenue(monthlyRevenue)
                .totalMissions(completedMissions.size())
                .revenueByMonth(revenueByMonth)
                .build();
    }
}
