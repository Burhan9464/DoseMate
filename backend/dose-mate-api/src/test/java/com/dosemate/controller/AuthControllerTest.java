package com.dosemate.controller;

import com.dosemate.dto.auth.AuthResponse;
import com.dosemate.dto.auth.LoginRequest;
import com.dosemate.dto.auth.RegisterRequest;
import com.dosemate.dto.user.UserProfileResponse;
import com.dosemate.entity.Gender;
import com.dosemate.exception.BusinessRuleException;
import com.dosemate.exception.ErrorCode;
import com.dosemate.security.CustomUserDetailsService;
import com.dosemate.security.JwtAuthenticationEntryPoint;
import com.dosemate.security.JwtService;
import com.dosemate.service.AuthService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AuthController.class)
@AutoConfigureMockMvc(addFilters = false) // Focus on controller and validation logic
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private AuthService authService;

    @MockBean
    private JwtService jwtService;

    @MockBean
    private CustomUserDetailsService userDetailsService;

    @MockBean
    private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;

    @Test
    @DisplayName("POST /api/v1/auth/register returns 201 Created on valid input")
    void testRegisterSuccess() throws Exception {
        RegisterRequest req = new RegisterRequest();
        req.setFullName("Alice Bob");
        req.setEmail("alice@example.com");
        req.setPassword("ValidPassword123!");
        req.setDateOfBirth(LocalDate.of(1990, 1, 1));
        req.setGender(Gender.FEMALE);
        req.setCountry("United Kingdom");

        UserProfileResponse up = new UserProfileResponse();
        up.setId(1L);
        up.setEmail("alice@example.com");
        up.setFullName("Alice Bob");

        AuthResponse authRes = new AuthResponse("jwt.token.string", 86400, up);
        when(authService.register(any(RegisterRequest.class))).thenReturn(authRes);

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.token").value("jwt.token.string"))
                .andExpect(jsonPath("$.data.user.email").value("alice@example.com"));
    }

    @Test
    @DisplayName("POST /api/v1/auth/register returns 400 VALIDATION_FAILED on invalid input")
    void testRegisterValidationFailure() throws Exception {
        RegisterRequest req = new RegisterRequest();
        req.setFullName(""); // Blank!
        req.setEmail("invalid-email"); // Invalid email!
        req.setPassword("short"); // Less than 8 chars!

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_FAILED"))
                .andExpect(jsonPath("$.details.email").exists())
                .andExpect(jsonPath("$.details.password").exists());
    }

    @Test
    @DisplayName("POST /api/v1/auth/register returns 409 DUPLICATE_EMAIL when email exists")
    void testRegisterDuplicateEmail() throws Exception {
        RegisterRequest req = new RegisterRequest();
        req.setFullName("Alice Bob");
        req.setEmail("existing@example.com");
        req.setPassword("ValidPassword123!");
        req.setDateOfBirth(LocalDate.of(1990, 1, 1));
        req.setGender(Gender.FEMALE);
        req.setCountry("United Kingdom");

        when(authService.register(any(RegisterRequest.class)))
                .thenThrow(new BusinessRuleException(ErrorCode.DUPLICATE_EMAIL));

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DUPLICATE_EMAIL"));
    }

    @Test
    @DisplayName("POST /api/v1/auth/login returns 200 OK on valid credentials")
    void testLoginSuccess() throws Exception {
        LoginRequest req = new LoginRequest("alice@example.com", "ValidPassword123!");

        UserProfileResponse up = new UserProfileResponse();
        up.setId(1L);
        up.setEmail("alice@example.com");

        AuthResponse authRes = new AuthResponse("jwt.token.string", 86400, up);
        when(authService.login(any(LoginRequest.class))).thenReturn(authRes);

        mockMvc.perform(post("/api/v1/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.token").value("jwt.token.string"));
    }
}
