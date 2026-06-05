package ma.skylark.msd.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import ma.skylark.msd.controller.dto.IntakeResponse;
import ma.skylark.msd.controller.dto.MedicationRequest;
import ma.skylark.msd.controller.dto.MedicationResponse;
import ma.skylark.msd.domain.entity.IntakeLog;
import ma.skylark.msd.domain.entity.Medication;
import ma.skylark.msd.domain.exception.MedicationException;
import ma.skylark.msd.domain.model.IntakeStatus;
import ma.skylark.msd.repository.IntakeLogRepository;
import ma.skylark.msd.repository.MedicationRepository;

/**
 * Service for managing medication plans and tracking daily intakes.
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MedicationService {

    private final MedicationRepository medicationRepository;
    private final IntakeLogRepository intakeLogRepository;

    /**
     * Creates a new medication and generates its scheduled intake logs.
     */
    @Transactional
    public MedicationResponse createMedication(MedicationRequest req, String userId) {
        Medication med = Medication.builder()
                .id(UUID.randomUUID())
                .userId(userId)
                .medicationName(req.medicationName())
                .dosage(req.dosage())
                .instructions(req.instructions())
                .startDate(req.startDate())
                .durationInDays(req.durationInDays())
                .initialStock(req.initialStock())
                .currentStock(req.initialStock())
                .lowStockThreshold(req.lowStockThreshold())
                .intakeTimes(req.intakeTimes())
                .reminderType(req.reminderType())
                .leadTimeMinutes(req.leadTimeMinutes())
                .snoozeIntervalMinutes(req.snoozeIntervalMinutes())
                .build();

        Medication saved = medicationRepository.save(med);
        generateIntakeLogs(saved);

        log.info("Medication '{}' created for user '{}'", saved.getMedicationName(), userId);
        return MedicationResponse.fromEntity(saved);
    }

    /**
     * Generates all pending intake slots for the duration of the treatment.
     */
    private void generateIntakeLogs(Medication med) {
        List<IntakeLog> logs = new ArrayList<>();
        List<LocalTime> times = med.getIntakeTimes();
        for (int i = 0; i < med.getDurationInDays(); i++) {
            LocalDate date = med.getStartDate().plusDays(i);
            for (int s = 0; s < times.size(); s++) {
                logs.add(IntakeLog.builder()
                        .id(UUID.randomUUID())
                        .medication(med)
                        .intakeDate(date)
                        .daySlotIndex(s)
                        .slotTime(times.get(s))
                        .status(IntakeStatus.PENDING)
                        .build());
            }
        }
        intakeLogRepository.saveAll(logs);
    }

    /**
     * Updates the status of a specific intake and synchronizes medication stock.
     *
     * @param actualTakenDateTime When marking {@code TAKEN}, optional; if {@code null}, {@link LocalDateTime#now()} is used
     */
    @Transactional
    public void updateIntakeStatus(UUID logId, IntakeStatus newStatus, LocalDateTime actualTakenDateTime,
            LocalTime slotTime) {
        boolean hasStatus = newStatus != null;
        boolean hasSlot = slotTime != null;
        if (!hasStatus && !hasSlot) {
            throw new MedicationException("Either status or slotTime is required");
        }

        IntakeLog logEntry = intakeLogRepository.findById(logId)
                .orElseThrow(() -> new MedicationException("Intake log not found with ID: " + logId));

        if (hasSlot) {
            logEntry.setSlotTime(slotTime);
        }

        if (!hasStatus) {
            intakeLogRepository.save(logEntry);
            return;
        }

        IntakeStatus oldStatus = logEntry.getStatus();
        Medication med = logEntry.getMedication();

        if (newStatus == IntakeStatus.TAKEN && oldStatus != IntakeStatus.TAKEN) {
            if (med.getCurrentStock() <= 0) {
                throw new MedicationException("Insufficient stock for medication: " + med.getMedicationName());
            }
            med.setCurrentStock(med.getCurrentStock() - 1);
            logEntry.setActualTakenDateTime(actualTakenDateTime != null ? actualTakenDateTime : LocalDateTime.now());
            logEntry.setStatus(IntakeStatus.TAKEN);
        } else if (newStatus == IntakeStatus.PENDING && oldStatus == IntakeStatus.TAKEN) {
            med.setCurrentStock(med.getCurrentStock() + 1);
            logEntry.setActualTakenDateTime(null);
            logEntry.setStatus(IntakeStatus.PENDING);
        } else {
            if (newStatus != IntakeStatus.TAKEN) {
                logEntry.setActualTakenDateTime(null);
            }
            logEntry.setStatus(newStatus);
        }

        intakeLogRepository.save(logEntry);
    }

    /**
     * Lists all medications for a user.
     */
    public List<MedicationResponse> getMyMedications(String userId) {
        return medicationRepository.findByUserId(userId).stream()
                .map(MedicationResponse::fromEntity)
                .toList();
    }

    /**
     * Lists daily intakes for the timeline view.
     * Maps entities to DTOs to respect architectural boundaries.
     */
    public List<IntakeResponse> getDailyIntakes(String userId, LocalDate date) {
        return intakeLogRepository.findDailyLogs(userId, date)
                .stream()
                .map(IntakeResponse::fromEntity)
                .toList();
    }
    /**
    * Retrieves the list of scheduled catches for a user over a given period.
    * This method optimizes performance by retrieving all logs in a single request
    * via the repository, then converting them into response objects (DTOs).
    * @param userId The unique identifier of the user.
    * @param startDate Start date of the range (inclusive).
    * @param endDate End date of the range (inclusive).
    * @return A list of {@link IntakeResponse} containing the details of the catches for the period.
    */
    
    public List<IntakeResponse> getIntakesForRange(String userId, LocalDate startDate, LocalDate endDate) {
    return intakeLogRepository.findLogsInRange(userId, startDate, endDate)
            .stream()
            .map(IntakeResponse::fromEntity)
            .toList();
    }

    /**
     * Updates the stock of a medication after verification of ownership.
     */
    @Transactional 
    public MedicationResponse updateStock(UUID id, int newStock, String userId) {
        // 1. Récupération et vérification de propriété
        Medication medication = medicationRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new MedicationException("Medication not found or access denied"));

        // 2. Mise à jour du stock
        medication.setCurrentStock(newStock);

        // 3. Sauvegarde et retour de la réponse mappée
        Medication saved = medicationRepository.save(medication);
        return MedicationResponse.fromEntity(saved);     }
}
