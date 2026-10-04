package com.dosemate.service;

import com.dosemate.dto.user.UpdateFlagsRequest;
import com.dosemate.dto.user.UpdateProfileRequest;
import com.dosemate.dto.user.UserProfileResponse;
import com.dosemate.entity.User;
import com.dosemate.exception.ResourceNotFoundException;
import com.dosemate.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserService {

    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public UserProfileResponse getProfile(Long userId) {
        User user = getUserOrThrow(userId);
        return UserProfileResponse.fromEntity(user);
    }

    @Transactional
    public UserProfileResponse updateProfile(Long userId, UpdateProfileRequest request) {
        User user = getUserOrThrow(userId);
        user.setFullName(request.getFullName().trim());
        user.setDateOfBirth(request.getDateOfBirth());
        user.setGender(request.getGender());
        user.setCountry(request.getCountry().trim());
        if (request.getTimezone() != null && !request.getTimezone().isBlank()) {
            user.setTimezone(request.getTimezone().trim());
        }

        User updatedUser = userRepository.save(user);
        return UserProfileResponse.fromEntity(updatedUser);
    }

    @Transactional
    public UserProfileResponse updateFlags(Long userId, UpdateFlagsRequest request) {
        User user = getUserOrThrow(userId);
        if (request.getOnboardingCompleted() != null) {
            user.setOnboardingCompleted(request.getOnboardingCompleted());
        }
        if (request.getGuideCompleted() != null) {
            user.setGuideCompleted(request.getGuideCompleted());
        }

        User updatedUser = userRepository.save(user);
        return UserProfileResponse.fromEntity(updatedUser);
    }

    private User getUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));
    }
}
