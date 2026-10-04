package com.dosemate.controller;

import com.dosemate.dto.common.ApiResponse;
import com.dosemate.dto.user.UpdateFlagsRequest;
import com.dosemate.dto.user.UpdateProfileRequest;
import com.dosemate.dto.user.UserProfileResponse;
import com.dosemate.service.UserService;
import com.dosemate.util.SecurityUtils;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserProfileResponse>> getProfile() {
        Long currentUserId = SecurityUtils.getCurrentUserId();
        UserProfileResponse response = userService.getProfile(currentUserId);
        return ResponseEntity.ok(ApiResponse.success(response, "Profile retrieved successfully"));
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<UserProfileResponse>> updateProfile(
            @Valid @RequestBody UpdateProfileRequest request) {
        Long currentUserId = SecurityUtils.getCurrentUserId();
        UserProfileResponse response = userService.updateProfile(currentUserId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "Profile updated successfully"));
    }

    @PatchMapping("/me/flags")
    public ResponseEntity<ApiResponse<UserProfileResponse>> updateFlags(
            @RequestBody UpdateFlagsRequest request) {
        Long currentUserId = SecurityUtils.getCurrentUserId();
        UserProfileResponse response = userService.updateFlags(currentUserId, request);
        return ResponseEntity.ok(ApiResponse.success(response, "App progress flags updated successfully"));
    }
}
