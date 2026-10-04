package com.dosemate.service;

import com.dosemate.dto.auth.AuthResponse;
import com.dosemate.dto.auth.LoginRequest;
import com.dosemate.dto.auth.RegisterRequest;
import com.dosemate.entity.Gender;
import com.dosemate.entity.User;
import com.dosemate.exception.BusinessRuleException;
import com.dosemate.exception.ErrorCode;
import com.dosemate.repository.UserRepository;
import com.dosemate.security.CustomUserDetails;
import com.dosemate.security.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDate;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    @Mock
    private AuthenticationManager authenticationManager;

    @InjectMocks
    private AuthService authService;

    private RegisterRequest registerRequest;

    @BeforeEach
    void setUp() {
        registerRequest = new RegisterRequest();
        registerRequest.setFullName("Jane Doe");
        registerRequest.setEmail("jane@example.com");
        registerRequest.setPassword("SecretPassword123!");
        registerRequest.setDateOfBirth(LocalDate.of(1995, 6, 15));
        registerRequest.setGender(Gender.FEMALE);
        registerRequest.setCountry("United States");
        registerRequest.setTimezone("America/New_York");
    }

    @Test
    @DisplayName("Registration succeeds and returns JWT and profile")
    void testRegisterSuccess() {
        when(userRepository.existsByEmail("jane@example.com")).thenReturn(false);
        when(passwordEncoder.encode(any())).thenReturn("hashedPassword");

        User savedUser = new User();
        savedUser.setId(1L);
        savedUser.setFullName("Jane Doe");
        savedUser.setEmail("jane@example.com");
        savedUser.setPasswordHash("hashedPassword");
        savedUser.setDateOfBirth(LocalDate.of(1995, 6, 15));
        savedUser.setGender(Gender.FEMALE);
        savedUser.setCountry("United States");
        savedUser.setTimezone("America/New_York");

        when(userRepository.save(any(User.class))).thenReturn(savedUser);
        when(jwtService.generateToken(any(CustomUserDetails.class))).thenReturn("fake.jwt.token");
        when(jwtService.getExpirationSeconds()).thenReturn(86400L);

        AuthResponse response = authService.register(registerRequest);

        assertThat(response).isNotNull();
        assertThat(response.getToken()).isEqualTo("fake.jwt.token");
        assertThat(response.getUser().getEmail()).isEqualTo("jane@example.com");
        assertThat(response.getUser().getFullName()).isEqualTo("Jane Doe");
        verify(userRepository).save(any(User.class));
    }

    @Test
    @DisplayName("Registration rejects duplicate email with DUPLICATE_EMAIL code")
    void testRegisterDuplicateEmail() {
        when(userRepository.existsByEmail("jane@example.com")).thenReturn(true);

        assertThatThrownBy(() -> authService.register(registerRequest))
                .isInstanceOf(BusinessRuleException.class)
                .satisfies(ex -> {
                    BusinessRuleException bre = (BusinessRuleException) ex;
                    assertThat(bre.getErrorCode()).isEqualTo(ErrorCode.DUPLICATE_EMAIL);
                });

        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    @DisplayName("Login succeeds with valid credentials")
    void testLoginSuccess() {
        LoginRequest loginRequest = new LoginRequest("jane@example.com", "SecretPassword123!");

        User user = new User();
        user.setId(1L);
        user.setFullName("Jane Doe");
        user.setEmail("jane@example.com");
        user.setPasswordHash("hashedPassword");
        user.setDateOfBirth(LocalDate.of(1995, 6, 15));
        user.setGender(Gender.FEMALE);
        user.setCountry("United States");

        CustomUserDetails userDetails = new CustomUserDetails(user);
        Authentication auth = mock(Authentication.class);
        when(auth.getPrincipal()).thenReturn(userDetails);

        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenReturn(auth);
        when(userRepository.findById(1L)).thenReturn(Optional.of(user));
        when(jwtService.generateToken(userDetails)).thenReturn("fake.jwt.token");
        when(jwtService.getExpirationSeconds()).thenReturn(86400L);

        AuthResponse response = authService.login(loginRequest);

        assertThat(response.getToken()).isEqualTo("fake.jwt.token");
        assertThat(response.getUser().getEmail()).isEqualTo("jane@example.com");
    }

    @Test
    @DisplayName("Login fails with invalid credentials")
    void testLoginBadCredentials() {
        LoginRequest loginRequest = new LoginRequest("jane@example.com", "WrongPassword");

        when(authenticationManager.authenticate(any(UsernamePasswordAuthenticationToken.class)))
                .thenThrow(new BadCredentialsException("Bad credentials"));

        assertThatThrownBy(() -> authService.login(loginRequest))
                .isInstanceOf(BadCredentialsException.class);
    }
}
