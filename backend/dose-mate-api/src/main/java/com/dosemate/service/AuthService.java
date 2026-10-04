package com.dosemate.service;

import com.dosemate.dto.auth.AuthResponse;
import com.dosemate.dto.auth.LoginRequest;
import com.dosemate.dto.auth.RegisterRequest;
import com.dosemate.dto.user.UserProfileResponse;
import com.dosemate.entity.User;
import com.dosemate.exception.BusinessRuleException;
import com.dosemate.exception.ErrorCode;
import com.dosemate.repository.UserRepository;
import com.dosemate.security.CustomUserDetails;
import com.dosemate.security.JwtService;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    public AuthService(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            AuthenticationManager authenticationManager) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        String cleanEmail = request.getEmail().trim().toLowerCase();

        if (userRepository.existsByEmail(cleanEmail)) {
            throw new BusinessRuleException(ErrorCode.DUPLICATE_EMAIL);
        }

        User user = new User();
        user.setFullName(request.getFullName().trim());
        user.setEmail(cleanEmail);
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setDateOfBirth(request.getDateOfBirth());
        user.setGender(request.getGender());
        user.setCountry(request.getCountry().trim());
        user.setTimezone(request.getTimezone() != null && !request.getTimezone().isBlank()
                ? request.getTimezone().trim()
                : "UTC");

        User savedUser = userRepository.save(user);

        CustomUserDetails userDetails = new CustomUserDetails(savedUser);
        String token = jwtService.generateToken(userDetails);
        long expiresIn = jwtService.getExpirationSeconds();

        return new AuthResponse(token, expiresIn, UserProfileResponse.fromEntity(savedUser));
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest request) {
        String cleanEmail = request.getEmail().trim().toLowerCase();

        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(cleanEmail, request.getPassword())
        );

        CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new BusinessRuleException(ErrorCode.INVALID_CREDENTIALS));

        String token = jwtService.generateToken(userDetails);
        long expiresIn = jwtService.getExpirationSeconds();

        return new AuthResponse(token, expiresIn, UserProfileResponse.fromEntity(user));
    }
}
