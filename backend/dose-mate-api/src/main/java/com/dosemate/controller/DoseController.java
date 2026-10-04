package com.dosemate.controller;

import com.dosemate.dto.common.ApiResponse;
import com.dosemate.dto.dose.DoseHistoryPageResponse;
import com.dosemate.dto.dose.DoseResponse;
import com.dosemate.dto.dose.DoseTakenResponse;
import com.dosemate.entity.DoseStatus;
import com.dosemate.service.DoseService;
import com.dosemate.util.SecurityUtils;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;

@RestController
@RequestMapping("/api/v1/doses")
public class DoseController {

    private final DoseService doseService;

    public DoseController(DoseService doseService) {
        this.doseService = doseService;
    }

    @GetMapping("/today")
    public ResponseEntity<ApiResponse<List<DoseResponse>>> getTodayDoses() {
        Long userId = SecurityUtils.getCurrentUserId();
        List<DoseResponse> doses = doseService.getTodayDoses(userId);
        return ResponseEntity.ok(ApiResponse.success(doses, "Today's doses retrieved successfully"));
    }

    @PostMapping("/{id}/taken")
    public ResponseEntity<ApiResponse<DoseTakenResponse>> markDoseTaken(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        DoseTakenResponse response = doseService.markDoseTaken(userId, id);
        return ResponseEntity.ok(ApiResponse.success(response, "Dose recorded as taken"));
    }

    @PostMapping("/{id}/skipped")
    public ResponseEntity<ApiResponse<DoseResponse>> markDoseSkipped(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        DoseResponse response = doseService.markDoseSkipped(userId, id);
        return ResponseEntity.ok(ApiResponse.success(response, "Dose marked as skipped"));
    }

    @PostMapping("/{id}/undo-skip")
    public ResponseEntity<ApiResponse<DoseResponse>> undoSkip(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        DoseResponse response = doseService.undoSkip(userId, id);
        return ResponseEntity.ok(ApiResponse.success(response, "Dose reverted to pending"));
    }

    @GetMapping("/history")
    public ResponseEntity<ApiResponse<DoseHistoryPageResponse>> getHistory(
            @RequestParam(required = false) DoseStatus status,
            @RequestParam(required = false) String search,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) Instant endDate,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        Long userId = SecurityUtils.getCurrentUserId();
        DoseHistoryPageResponse history = doseService.getHistory(userId, status, search, startDate, endDate, page, size);
        return ResponseEntity.ok(ApiResponse.success(history, "Medication history retrieved successfully"));
    }
}
