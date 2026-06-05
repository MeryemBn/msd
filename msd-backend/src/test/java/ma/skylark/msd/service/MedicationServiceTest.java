package ma.skylark.msd.service;

import ma.skylark.msd.controller.dto.IntakeResponse;
import ma.skylark.msd.controller.dto.MedicationRequest;
import ma.skylark.msd.controller.dto.MedicationResponse;
import ma.skylark.msd.domain.entity.IntakeLog;
import ma.skylark.msd.domain.entity.Medication;
import ma.skylark.msd.domain.exception.MedicationException;
import ma.skylark.msd.domain.model.IntakeStatus;
import ma.skylark.msd.repository.IntakeLogRepository;
import ma.skylark.msd.repository.MedicationRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class MedicationServiceTest {

    private MedicationRepository medicationRepository;
    private IntakeLogRepository intakeLogRepository;
    private MedicationService medicationService;

    @BeforeEach
    void setup() {
        medicationRepository = Mockito.mock(MedicationRepository.class);
        intakeLogRepository = Mockito.mock(IntakeLogRepository.class);

        medicationService = new MedicationService(medicationRepository, intakeLogRepository);
    }

    // ===================== create medication =====================
    @Test
    @DisplayName("Create Medication - Success")
    void testCreateMedication() {
        MedicationRequest request = new MedicationRequest(
                "Ibuprofen",
                "200mg",
                "After meals",
                LocalDate.now(),
                7,
                List.of(LocalTime.of(8,0), LocalTime.of(20,0)),
                20,
                5
        );

        Medication savedMedication = Medication.builder()
                .id(UUID.randomUUID())
                .userId("user123")
                .medicationName("Ibuprofen")
                .dosage("200mg")
                .instructions("After meals")
                .startDate(LocalDate.now())
                .durationInDays(7)
                .initialStock(20)
                .currentStock(20)
                .lowStockThreshold(5)
                .intakeTimes(List.of(LocalTime.of(8, 0), LocalTime.of(20, 0)))
                .build();

        when(medicationRepository.save(any(Medication.class))).thenReturn(savedMedication);

        MedicationResponse response = medicationService.createMedication(request, "user123");

        assertNotNull(response);
        assertEquals("Ibuprofen", response.medicationName());
        verify(intakeLogRepository, times(1)).saveAll(anyList());
    }

    // ===================== list medications =====================
    @Test
    @DisplayName("Get My Medications - Success")
    void testGetMyMedications() {
        Medication med = Medication.builder()
                .id(UUID.randomUUID())
                .userId("user123")
                .medicationName("Paracetamol")
                .dosage("500mg")
                .instructions("After meals")
                .startDate(LocalDate.now())
                .durationInDays(7)
                .initialStock(20)
                .currentStock(20)
                .lowStockThreshold(5)
                .intakeTimes(List.of(LocalTime.of(8, 0), LocalTime.of(20, 0)))
                .build();
        when(medicationRepository.findByUserId("user123")).thenReturn(List.of(med));

        List<MedicationResponse> meds = medicationService.getMyMedications("user123");

        assertEquals(1, meds.size());
        assertEquals("Paracetamol", meds.get(0).medicationName());
    }

    // ===================== update intake status =====================
    @Test
    @DisplayName("Update Intake Status - TAKEN reduces stock")
    void testUpdateIntakeStatusTaken() {
        Medication med = Medication.builder()
                .id(UUID.randomUUID())
                .medicationName("Ibuprofen")
                .currentStock(10)
                .build();

        IntakeLog log = IntakeLog.builder()
                .id(UUID.randomUUID())
                .medication(med)
                .intakeDate(LocalDate.now())
                .daySlotIndex(0)
                .slotTime(LocalTime.of(8, 0))
                .status(IntakeStatus.PENDING)
                .build();

        when(intakeLogRepository.findById(log.getId())).thenReturn(Optional.of(log));

        medicationService.updateIntakeStatus(log.getId(), IntakeStatus.TAKEN, null, null);

        assertEquals(IntakeStatus.TAKEN, log.getStatus());
        assertEquals(9, med.getCurrentStock());
        verify(intakeLogRepository).save(log);
    }

    @Test
    @DisplayName("Undo TAKEN intake always sets PENDING")
    void testUndoTakenIntake() {
        Medication med = Medication.builder()
                .id(UUID.randomUUID())
                .medicationName("Ibuprofen")
                .currentStock(5)
                .build();

        IntakeLog log = IntakeLog.builder()
                .id(UUID.randomUUID())
                .medication(med)
                .intakeDate(LocalDate.now())
                .daySlotIndex(0)
                .slotTime(LocalTime.of(8, 0))
                .status(IntakeStatus.TAKEN)
                .build();

        when(intakeLogRepository.findById(log.getId())).thenReturn(Optional.of(log));

        medicationService.updateIntakeStatus(log.getId(), IntakeStatus.PENDING, null, null);

        assertEquals(6, med.getCurrentStock());
        assertEquals(IntakeStatus.PENDING, log.getStatus());
        assertNull(log.getActualTakenDateTime());
    }

    @Test
    @DisplayName("TAKEN persists actualTakenDateTime when provided")
    void testTakenWithUserReportedTime() {
        Medication med = Medication.builder()
                .id(UUID.randomUUID())
                .medicationName("Ibuprofen")
                .currentStock(10)
                .intakeTimes(List.of(LocalTime.of(8, 0)))
                .build();

        IntakeLog log = IntakeLog.builder()
                .id(UUID.randomUUID())
                .medication(med)
                .intakeDate(LocalDate.now())
                .daySlotIndex(0)
                .slotTime(LocalTime.of(8, 0))
                .status(IntakeStatus.PENDING)
                .build();

        when(intakeLogRepository.findById(log.getId())).thenReturn(Optional.of(log));

        var reported = LocalDate.now().atTime(8, 45);
        medicationService.updateIntakeStatus(log.getId(), IntakeStatus.TAKEN, reported, null);

        assertEquals(IntakeStatus.TAKEN, log.getStatus());
        assertEquals(reported, log.getActualTakenDateTime());
    }

    @Test
    @DisplayName("updateIntakeStatus requires status or slotTime")
    void testUpdateIntakeStatusRequiresAtLeastOne() {
        assertThrows(MedicationException.class,
                () -> medicationService.updateIntakeStatus(UUID.randomUUID(), null, null, null));
    }

    @Test
    @DisplayName("PATCH slot only updates slotTime")
    void testUpdateIntakeSlotTimeOnly() {
        Medication med = Medication.builder()
                .id(UUID.randomUUID())
                .medicationName("Ibuprofen")
                .build();

        IntakeLog log = IntakeLog.builder()
                .id(UUID.randomUUID())
                .medication(med)
                .intakeDate(LocalDate.now())
                .daySlotIndex(0)
                .slotTime(LocalTime.of(8, 0))
                .status(IntakeStatus.PENDING)
                .build();

        when(intakeLogRepository.findById(log.getId())).thenReturn(Optional.of(log));

        medicationService.updateIntakeStatus(log.getId(), null, null, LocalTime.of(10, 30));

        assertEquals(LocalTime.of(10, 30), log.getSlotTime());
        assertEquals(IntakeStatus.PENDING, log.getStatus());
        verify(intakeLogRepository).save(log);
    }

    // ===================== daily intakes =====================
    @Test
    @DisplayName("Get Daily Intakes - Success")
    void testGetDailyIntakes() {
        Medication med = Medication.builder()
                .id(UUID.randomUUID())
                .medicationName("Paracetamol")
                .currentStock(20)
                .lowStockThreshold(5)
                .intakeTimes(List.of(LocalTime.of(8, 0), LocalTime.of(20, 0)))
                .build();

        IntakeLog intakeLog = IntakeLog.builder()
                .id(UUID.randomUUID())
                .medication(med)
                .intakeDate(LocalDate.now())
                .daySlotIndex(0)
                .slotTime(LocalTime.of(8, 0))
                .status(IntakeStatus.PENDING)
                .build();
        when(intakeLogRepository.findDailyLogs(anyString(), any(LocalDate.class)))
                .thenReturn(List.of(intakeLog));

        List<IntakeResponse> dailyIntakes = medicationService.getDailyIntakes("user123", LocalDate.now());

        assertEquals(1, dailyIntakes.size());
        assertEquals(IntakeStatus.PENDING.name(), dailyIntakes.get(0).status());
    }
}
