package ma.skylark.msd.controller;

import ma.skylark.msd.config.SecurityConfig;
import ma.skylark.msd.controller.dto.SosRequestResponse;
import ma.skylark.msd.exception.GlobalExceptionHandler;
import ma.skylark.msd.service.SosRequestService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Slice test for SosRequestController.
 * Security filters are active — authenticated endpoints use jwt() post-processor.
 */
@WebMvcTest(SosRequestController.class)
@Import({GlobalExceptionHandler.class, SecurityConfig.class})
class SosRequestControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private SosRequestService sosRequestService;

    private SosRequestResponse sampleResponse() {
        return new SosRequestResponse(
                UUID.randomUUID(),
                12L, null,
                "ambulance", "urgent", null,
                "sos_urgency", null, "card",
                BigDecimal.valueOf(120.00), null,
                "pending", null,
                LocalDateTime.of(2026, 4, 28, 18, 30),
                LocalDateTime.of(2026, 4, 28, 18, 30)
        );
    }

    // ===================== create SOS request =====================
    @Test
    @DisplayName("POST /api/sos-requests - creates request")
    void createSosRequest() throws Exception {
        when(sosRequestService.createRequest(any(), anyString())).thenReturn(sampleResponse());

        mockMvc.perform(post("/api/sos-requests")
                        .with(jwt().jwt(j -> j.tokenValue("test-token").subject("user-id")))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "serviceType": "ambulance",
                                  "ambulanceType": "urgent",
                                  "interventionMode": "sos_urgency",
                                  "paymentMethod": "card",
                                  "basePrice": 120.00,
                                  "location": {
                                    "address": "45 Main Street",
                                    "apartment": "A2",
                                    "floor": "2",
                                    "entryCode": "1234",
                                    "latitude": 36.8065,
                                    "longitude": 10.1815
                                  }
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.serviceType").value("ambulance"))
                .andExpect(jsonPath("$.status").value("pending"));
    }

    // ===================== get my SOS requests =====================
    @Test
    @DisplayName("GET /api/sos-requests - returns logged-in user requests")
    void getMyRequests() throws Exception {
        when(sosRequestService.getMyRequests(anyString())).thenReturn(List.of(sampleResponse()));

        mockMvc.perform(get("/api/sos-requests")
                        .with(jwt().jwt(j -> j.tokenValue("test-token").subject("user-id"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].serviceType").value("ambulance"))
                .andExpect(jsonPath("$[0].status").value("pending"));
    }

    // ===================== create validation =====================
    @Test
    @DisplayName("POST /api/sos-requests - validation error")
    void createSosRequestValidationError() throws Exception {
        mockMvc.perform(post("/api/sos-requests")
                        .with(jwt().jwt(j -> j.tokenValue("test-token").subject("user-id")))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "interventionMode": "sos_urgency",
                                  "paymentMethod": "card",
                                  "location": {
                                    "address": "45 Main Street",
                                    "latitude": 36.8065,
                                    "longitude": 10.1815
                                  }
                                }
                                """))
                .andExpect(status().isBadRequest());
    }
}
