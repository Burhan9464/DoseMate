package com.dosemate.controller;

import com.dosemate.dto.dose.DoseResponse;
import com.dosemate.dto.dose.DoseTakenResponse;
import com.dosemate.entity.DoseStatus;
import com.dosemate.entity.MedicineType;
import com.dosemate.entity.User;
import com.dosemate.exception.BusinessRuleException;
import com.dosemate.exception.ErrorCode;
import com.dosemate.security.CustomUserDetails;
import com.dosemate.security.CustomUserDetailsService;
import com.dosemate.security.JwtAuthenticationEntryPoint;
import com.dosemate.security.JwtService;
import com.dosemate.service.DoseService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.List;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(DoseController.class)
@AutoConfigureMockMvc(addFilters = false)
class DoseControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private DoseService doseService;

    @MockBean
    private JwtService jwtService;

    @MockBean
    private CustomUserDetailsService userDetailsService;

    @MockBean
    private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;

    @BeforeEach
    void setUp() {
        User user = new User();
        user.setId(1L);
        user.setEmail("user@example.com");
        CustomUserDetails userDetails = new CustomUserDetails(user);

        UsernamePasswordAuthenticationToken auth =
                new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    @Test
    @DisplayName("GET /api/v1/doses/today returns list of today's doses")
    void testGetTodayDoses() throws Exception {
        DoseResponse dose = new DoseResponse();
        dose.setId(101L);
        dose.setMedicineName("Amoxicillin");
        dose.setStatus(DoseStatus.PENDING);
        dose.setScheduledAt(Instant.now());

        when(doseService.getTodayDoses(1L)).thenReturn(List.of(dose));

        mockMvc.perform(get("/api/v1/doses/today"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].id").value(101))
                .andExpect(jsonPath("$.data[0].medicineName").value("Amoxicillin"));
    }

    @Test
    @DisplayName("POST /api/v1/doses/{id}/taken records dose taken and returns remaining inventory")
    void testMarkDoseTaken() throws Exception {
        DoseResponse dose = new DoseResponse();
        dose.setId(101L);
        dose.setStatus(DoseStatus.TAKEN);
        dose.setType(MedicineType.CAPSULE);

        DoseTakenResponse takenResponse = new DoseTakenResponse(dose, 19, false);
        when(doseService.markDoseTaken(eq(1L), eq(101L))).thenReturn(takenResponse);

        mockMvc.perform(post("/api/v1/doses/101/taken"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.dose.status").value("TAKEN"))
                .andExpect(jsonPath("$.data.remainingInventory").value(19))
                .andExpect(jsonPath("$.data.lowStock").value(false));
    }

    @Test
    @DisplayName("POST /api/v1/doses/{id}/taken returns 409 DOSE_ALREADY_COMPLETED on duplicate submission")
    void testDuplicateTakeRejection() throws Exception {
        when(doseService.markDoseTaken(eq(1L), eq(101L)))
                .thenThrow(new BusinessRuleException(ErrorCode.DOSE_ALREADY_COMPLETED));

        mockMvc.perform(post("/api/v1/doses/101/taken"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DOSE_ALREADY_COMPLETED"));
    }

    @Test
    @DisplayName("POST /api/v1/doses/{id}/skipped marks dose as skipped")
    void testMarkDoseSkipped() throws Exception {
        DoseResponse dose = new DoseResponse();
        dose.setId(101L);
        dose.setStatus(DoseStatus.SKIPPED);

        when(doseService.markDoseSkipped(eq(1L), eq(101L))).thenReturn(dose);

        mockMvc.perform(post("/api/v1/doses/101/skipped"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("SKIPPED"));
    }
}
