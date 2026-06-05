package ma.skylark.msd.controller;

import ma.skylark.msd.config.SecurityConfig;
import ma.skylark.msd.controller.dto.IntakeResponse;
import ma.skylark.msd.controller.dto.MedicationResponse;
import ma.skylark.msd.domain.model.IntakeStatus;
import ma.skylark.msd.exception.GlobalExceptionHandler;
import ma.skylark.msd.service.MedicationService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Slice test for MedicationController.
 * <p>
 * Security filters are active — authenticated endpoints use jwt() post-processor.
 */
@WebMvcTest(MedicationController.class)
@Import({GlobalExceptionHandler.class, SecurityConfig.class})
class MedicationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private MedicationService medicationService;

    // ===================== get my medications =====================
    @Test
    @DisplayName("GET /api/medications - success")
    void testGetMyMedications() throws Exception {
        MedicationResponse med = new MedicationResponse(
                UUID.randomUUID(),
                "Paracetamol",
                "500mg",
                "After meals",
                LocalDate.now(),
                7,
                20,
                List.of(LocalTime.of(8, 0), LocalTime.of(20, 0)),
                true
        );
        when(medicationService.getMyMedications(anyString())).thenReturn(List.of(med));

        mockMvc.perform(get("/api/medications")
                        .with(jwt().jwt(j -> j.tokenValue("test-token").subject("user-id"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].medicationName").value("Paracetamol"));
    }

    // ===================== create medication =====================
    @Test
    @DisplayName("POST /api/medications - create")
    void testAddMedication() throws Exception {
        MedicationResponse response = new MedicationResponse(
                UUID.randomUUID(),
                "Ibuprofen",
                "200mg",
                "After meals",
                LocalDate.now(),
                7,
                20,
                List.of(LocalTime.of(8, 0), LocalTime.of(20, 0)),
                true
        );
        when(medicationService.createMedication(any(), anyString())).thenReturn(response);

        mockMvc.perform(post("/api/medications")
                        .with(jwt().jwt(j -> j.tokenValue("test-token").subject("user-id")))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                    "medicationName": "Ibuprofen",
                                    "dosage": "200mg",
                                    "instructions": "After meals",
                                    "startDate": "%s",
                                    "durationInDays": 7,
                                    "intakeTimes": ["08:00:00", "20:00:00"],
                                    "initialStock": 20,
                                    "lowStockThreshold": 5
                                }
                                """.formatted(LocalDate.now())))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.medicationName").value("Ibuprofen"));
    }

    // ===================== get daily intakes =====================
    @Test
    @DisplayName("GET /api/medications/intakes - success")
    void testGetDailyIntakes() throws Exception {
        LocalDate date = LocalDate.now();
        IntakeResponse intake = new IntakeResponse(
                UUID.randomUUID(),
                UUID.randomUUID(),
                LocalDate.now(),
                LocalTime.of(8, 0),
                null,
                IntakeStatus.PENDING.name()
        );
        when(medicationService.getDailyIntakes(anyString(), any(LocalDate.class))).thenReturn(List.of(intake));

        mockMvc.perform(get("/api/medications/intakes")
                        .param("date", date.toString())
                        .with(jwt().jwt(j -> j.tokenValue("test-token").subject("user-id"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].status").value("PENDING"));
    }

    // ===================== update intake status =====================
    @Test
    @DisplayName("PATCH /api/medications/intakes/{id} - success")
    void testUpdateIntakeStatus() throws Exception {
        UUID logId = UUID.randomUUID();
        doNothing().when(medicationService).updateIntakeStatus(eq(logId), eq(IntakeStatus.TAKEN), isNull(), isNull());

        mockMvc.perform(patch("/api/medications/intakes/{id}", logId)
                        .with(jwt().jwt(j -> j.tokenValue("test-token").subject("user-id")))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                    "status": "TAKEN"
                                }
                                """))
                .andExpect(status().isOk());

        verify(medicationService).updateIntakeStatus(eq(logId), eq(IntakeStatus.TAKEN), isNull(), isNull());
    }

    @Test
    @DisplayName("PATCH /api/medications/intakes/{id} - slotTime only")
    void testUpdateIntakeSlotOnly() throws Exception {
        UUID logId = UUID.randomUUID();
        doNothing().when(medicationService).updateIntakeStatus(eq(logId), isNull(), isNull(), eq(LocalTime.of(9, 15)));

        mockMvc.perform(patch("/api/medications/intakes/{id}", logId)
                        .with(jwt().jwt(j -> j.tokenValue("test-token").subject("user-id")))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                    "slotTime": "09:15:00"
                                }
                                """))
                .andExpect(status().isOk());

        verify(medicationService).updateIntakeStatus(eq(logId), isNull(), isNull(), eq(LocalTime.of(9, 15)));
    }
}
