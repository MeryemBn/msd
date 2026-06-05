package ma.skylark.msd.service;

import ma.skylark.msd.controller.dto.CreateSosRequest;
import ma.skylark.msd.controller.dto.LocationDetailsRequest;
import ma.skylark.msd.domain.entity.SosRequest;
import ma.skylark.msd.domain.entity.UserProfile;
import ma.skylark.msd.domain.exception.SosRequestException;
import ma.skylark.msd.domain.model.AmbulanceType;
import ma.skylark.msd.domain.model.InterventionMode;
import ma.skylark.msd.domain.model.PaymentMethod;
import ma.skylark.msd.domain.model.ServiceType;
import ma.skylark.msd.domain.model.Specialty;
import ma.skylark.msd.repository.SosRequestRepository;
import ma.skylark.msd.repository.UserProfileRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

/**
 * Unit tests for SOS request creation business rules.
 */
class SosRequestServiceTest {

    private SosRequestRepository sosRequestRepository;
    private UserProfileRepository userProfileRepository;
    private SosRequestService sosRequestService;

    @BeforeEach
    void setup() {
        sosRequestRepository = Mockito.mock(SosRequestRepository.class);
        userProfileRepository = Mockito.mock(UserProfileRepository.class);
        sosRequestService = new SosRequestService(sosRequestRepository, userProfileRepository);
    }

    // ===================== create SOS request =====================
    @Test
    @DisplayName("Create SOS Request - Success")
    void createSuccess() {
        UserProfile profile = new UserProfile("user-sub");
        profile.setId(12L);
        when(userProfileRepository.findByKeycloakId("user-sub")).thenReturn(Optional.of(profile));
        when(sosRequestRepository.save(any(SosRequest.class))).thenAnswer(i -> i.getArgument(0));

        CreateSosRequest request = new CreateSosRequest(
                "ambulance",
                "urgent",
                null,
                "sos_urgency",
                null,
                "card",
                new BigDecimal("120.00"),
                new LocationDetailsRequest("45 Main Street", "A2", "2", "1234", 36.8065, 10.1815)
        );

        var response = sosRequestService.createRequest(request, "user-sub");

        assertNotNull(response.id());
        assertEquals(12L, response.patientId());
        assertEquals("ambulance", response.serviceType());
        assertEquals("pending", response.status());
    }

    // ===================== profile resolution =====================
    @Test
    @DisplayName("Create SOS Request - Missing profile creates minimal profile")
    void createMissingProfileCreatesProfile() {
        UserProfile createdProfile = new UserProfile("missing");
        createdProfile.setId(33L);
        when(userProfileRepository.findByKeycloakId("missing")).thenReturn(Optional.empty());
        when(userProfileRepository.save(any(UserProfile.class))).thenReturn(createdProfile);
        when(sosRequestRepository.save(any(SosRequest.class))).thenAnswer(i -> i.getArgument(0));

        CreateSosRequest request = new CreateSosRequest(
                "ambulance",
                "urgent",
                null,
                "sos_urgency",
                null,
                "card",
                new BigDecimal("120.00"),
                new LocationDetailsRequest("45 Main Street", null, null, null, 36.8065, 10.1815)
        );

        var response = sosRequestService.createRequest(request, "missing");
        assertEquals(33L, response.patientId());
    }

    // ===================== business rules =====================
    @Test
    @DisplayName("Create SOS Request - appointment requires datetime")
    void appointmentRequiresDatetime() {
        UserProfile profile = new UserProfile("user-sub");
        profile.setId(12L);
        when(userProfileRepository.findByKeycloakId("user-sub")).thenReturn(Optional.of(profile));

        CreateSosRequest request = new CreateSosRequest(
                "doctor_home",
                null,
                "cardiology",
                "appointment",
                null,
                "card",
                new BigDecimal("120.00"),
                new LocationDetailsRequest("45 Main Street", null, null, null, 36.8065, 10.1815)
        );

        assertThrows(IllegalArgumentException.class, () -> sosRequestService.createRequest(request, "user-sub"));
    }

    @Test
    @DisplayName("Create SOS Request - consultation requires specialty")
    void consultationRequiresSpecialty() {
        UserProfile profile = new UserProfile("user-sub");
        profile.setId(12L);
        when(userProfileRepository.findByKeycloakId("user-sub")).thenReturn(Optional.of(profile));

        CreateSosRequest request = new CreateSosRequest(
                "teleconsultation",
                null,
                null,
                "sos_urgency",
                LocalDateTime.now(),
                "card",
                new BigDecimal("120.00"),
                new LocationDetailsRequest("45 Main Street", null, null, null, 36.8065, 10.1815)
        );

        assertThrows(IllegalArgumentException.class, () -> sosRequestService.createRequest(request, "user-sub"));
    }

    @Test
    @DisplayName("Create SOS Request - ambulance requires ambulanceType")
    void ambulanceRequiresAmbulanceType() {
        UserProfile profile = new UserProfile("user-sub");
        profile.setId(12L);
        when(userProfileRepository.findByKeycloakId("user-sub")).thenReturn(Optional.of(profile));

        CreateSosRequest request = new CreateSosRequest(
                "ambulance",
                null,
                null,
                "sos_urgency",
                null,
                "card",
                new BigDecimal("120.00"),
                new LocationDetailsRequest("45 Main Street", null, null, null, 36.8065, 10.1815)
        );

        assertThrows(IllegalArgumentException.class, () -> sosRequestService.createRequest(request, "user-sub"));
    }

    @Test
    @DisplayName("Create SOS Request - prevent double booking at same time")
    void preventDoubleBookingSameTime() {
        // Setup patient profile
        UserProfile patientProfile = new UserProfile("patient-123");
        patientProfile.setId(10L);
        when(userProfileRepository.findByKeycloakId("patient-123")).thenReturn(Optional.of(patientProfile));

        // Setup professional profile
        UserProfile professionalProfile = new UserProfile("pro-456");
        professionalProfile.setId(20L);
        when(userProfileRepository.existsById(20L)).thenReturn(true);

        LocalDateTime appointmentTime = LocalDateTime.of(2026, 5, 26, 10, 0);

        // Mock that professional already has appointment at this time
        when(sosRequestRepository.existsByProfessionalIdAndAppointmentDatetime(eq(20L), eq(appointmentTime)))
                .thenReturn(true);

        CreateSosRequest request = new CreateSosRequest(
                ServiceType.DOCTOR,
                null,
                Specialty.CARDIOLOGIE,
                InterventionMode.APPOINTMENT,
                appointmentTime,
                PaymentMethod.BANK_CARD,
                new BigDecimal("150.00"),
                new LocationDetailsRequest("123 Health Street", null, null, null, 36.8065, 10.1815),
                20L
        );

        SosRequestException exception = assertThrows(
                SosRequestException.class,
                () -> sosRequestService.createRequest(request, "patient-123")
        );

        assertEquals("Le professionnel a déjà un rendez-vous à cette heure. Veuillez choisir un autre créneau horaire.",
                exception.getMessage());
    }

    @Test
    @DisplayName("Create SOS Request - allow booking when professional is available")
    void allowBookingWhenProfessionalAvailable() {
        // Setup patient profile
        UserProfile patientProfile = new UserProfile("patient-123");
        patientProfile.setId(10L);
        when(userProfileRepository.findByKeycloakId("patient-123")).thenReturn(Optional.of(patientProfile));

        // Setup professional profile
        UserProfile professionalProfile = new UserProfile("pro-456");
        professionalProfile.setId(20L);
        when(userProfileRepository.existsById(20L)).thenReturn(true);
        when(userProfileRepository.findById(20L)).thenReturn(Optional.of(professionalProfile));

        LocalDateTime appointmentTime = LocalDateTime.of(2026, 5, 26, 14, 0);

        // Mock that professional is available at this time
        when(sosRequestRepository.existsByProfessionalIdAndAppointmentDatetime(eq(20L), eq(appointmentTime)))
                .thenReturn(false);

        when(sosRequestRepository.save(any(SosRequest.class))).thenAnswer(i -> i.getArgument(0));

        CreateSosRequest request = new CreateSosRequest(
                ServiceType.DOCTOR,
                null,
                Specialty.CARDIOLOGIE,
                InterventionMode.APPOINTMENT,
                appointmentTime,
                PaymentMethod.BANK_CARD,
                new BigDecimal("150.00"),
                new LocationDetailsRequest("123 Health Street", null, null, null, 36.8065, 10.1815),
                20L
        );

        var response = sosRequestService.createRequest(request, "patient-123");

        assertNotNull(response.id());
        assertEquals(10L, response.patientId());
        assertEquals(20L, response.professionalId());
        assertEquals("pending", response.status());
    }

    @Test
    @DisplayName("Create SOS Request - prevent patient from having multiple ongoing appointments with same professional")
    void preventMultipleOngoingAppointmentsWithSameProfessional() {
        // Setup patient profile
        UserProfile patientProfile = new UserProfile("patient-123");
        patientProfile.setId(10L);
        when(userProfileRepository.findByKeycloakId("patient-123")).thenReturn(Optional.of(patientProfile));

        // Setup professional profile
        when(userProfileRepository.existsById(20L)).thenReturn(true);

        LocalDateTime appointmentTime = LocalDateTime.of(2026, 5, 26, 14, 0);

        // Mock that patient already has an ongoing appointment with this professional
        when(sosRequestRepository.existsOngoingAppointmentByPatientAndProfessional(eq(10L), eq(20L)))
                .thenReturn(true);

        CreateSosRequest request = new CreateSosRequest(
                ServiceType.DOCTOR,
                null,
                Specialty.CARDIOLOGIE,
                InterventionMode.APPOINTMENT,
                appointmentTime,
                PaymentMethod.BANK_CARD,
                new BigDecimal("150.00"),
                new LocationDetailsRequest("123 Health Street", null, null, null, 36.8065, 10.1815),
                20L
        );

        SosRequestException exception = assertThrows(
                SosRequestException.class,
                () -> sosRequestService.createRequest(request, "patient-123")
        );

        assertEquals("Vous avez déjà un rendez-vous en cours avec ce professionnel. Veuillez le compléter avant d'en créer un nouveau.",
                exception.getMessage());
    }

    @Test
    @DisplayName("Create SOS Request - allow patient to book with same professional after previous appointment is completed")
    void allowBookingWithSameProfessionalAfterCompletion() {
        // Setup patient profile
        UserProfile patientProfile = new UserProfile("patient-123");
        patientProfile.setId(10L);
        when(userProfileRepository.findByKeycloakId("patient-123")).thenReturn(Optional.of(patientProfile));

        // Setup professional profile
        UserProfile professionalProfile = new UserProfile("pro-456");
        professionalProfile.setId(20L);
        when(userProfileRepository.existsById(20L)).thenReturn(true);
        when(userProfileRepository.findById(20L)).thenReturn(Optional.of(professionalProfile));

        LocalDateTime appointmentTime = LocalDateTime.of(2026, 5, 26, 14, 0);

        // Mock that patient does NOT have ongoing appointment (previous one was completed)
        when(sosRequestRepository.existsOngoingAppointmentByPatientAndProfessional(eq(10L), eq(20L)))
                .thenReturn(false);

        // Mock that time slot is available
        when(sosRequestRepository.existsByProfessionalIdAndAppointmentDatetime(eq(20L), eq(appointmentTime)))
                .thenReturn(false);

        when(sosRequestRepository.save(any(SosRequest.class))).thenAnswer(i -> i.getArgument(0));

        CreateSosRequest request = new CreateSosRequest(
                ServiceType.DOCTOR,
                null,
                Specialty.CARDIOLOGIE,
                InterventionMode.APPOINTMENT,
                appointmentTime,
                PaymentMethod.BANK_CARD,
                new BigDecimal("150.00"),
                new LocationDetailsRequest("123 Health Street", null, null, null, 36.8065, 10.1815),
                20L
        );

        var response = sosRequestService.createRequest(request, "patient-123");

        assertNotNull(response.id());
        assertEquals(10L, response.patientId());
        assertEquals(20L, response.professionalId());
        assertEquals("pending", response.status());
    }

    @Test
    @DisplayName("Create SOS Request - time slot conflict has specific error message")
    void timeSlotConflictHasSpecificMessage() {
        // Setup patient profile
        UserProfile patientProfile = new UserProfile("patient-123");
        patientProfile.setId(10L);
        when(userProfileRepository.findByKeycloakId("patient-123")).thenReturn(Optional.of(patientProfile));

        // Setup professional
        when(userProfileRepository.existsById(20L)).thenReturn(true);

        LocalDateTime appointmentTime = LocalDateTime.of(2026, 5, 26, 10, 0);

        // Mock: no ongoing appointment with this professional
        when(sosRequestRepository.existsOngoingAppointmentByPatientAndProfessional(eq(10L), eq(20L)))
                .thenReturn(false);

        // Mock: time slot is already taken by another patient
        when(sosRequestRepository.existsByProfessionalIdAndAppointmentDatetime(eq(20L), eq(appointmentTime)))
                .thenReturn(true);

        CreateSosRequest request = new CreateSosRequest(
                ServiceType.DOCTOR,
                null,
                Specialty.CARDIOLOGIE,
                InterventionMode.APPOINTMENT,
                appointmentTime,
                PaymentMethod.BANK_CARD,
                new BigDecimal("150.00"),
                new LocationDetailsRequest("123 Health Street", null, null, null, 36.8065, 10.1815),
                20L
        );

        SosRequestException exception = assertThrows(
                SosRequestException.class,
                () -> sosRequestService.createRequest(request, "patient-123")
        );

        assertEquals("Ce créneau horaire est déjà pris. Le professionnel a un autre rendez-vous à cette heure. Veuillez choisir un autre créneau.",
                exception.getMessage());
    }
}
