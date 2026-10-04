package com.dosemate.controller;

import com.dosemate.dto.common.ApiResponse;
import com.dosemate.dto.dashboard.DashboardResponse;
import com.dosemate.service.DashboardService;
import com.dosemate.util.SecurityUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/dashboard")
public class DashboardController {

    private final DashboardService dashboardService;

    public DashboardController(DashboardService dashboardService) {
        this.dashboardService = dashboardService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<DashboardResponse>> getDashboard() {
        Long userId = SecurityUtils.getCurrentUserId();
        DashboardResponse response = dashboardService.getDashboard(userId);
        return ResponseEntity.ok(ApiResponse.success(response, "Dashboard data retrieved successfully"));
    }
}
