package com.dosemate.controller;

import com.dosemate.dto.common.ApiResponse;
import com.dosemate.dto.medicine.CreateMedicineRequest;
import com.dosemate.dto.medicine.MedicineResponse;
import com.dosemate.dto.medicine.MedicineSummaryResponse;
import com.dosemate.dto.medicine.UpdateMedicineRequest;
import com.dosemate.entity.MedicineStatus;
import com.dosemate.service.MedicineService;
import com.dosemate.util.SecurityUtils;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/medicines")
public class MedicineController {

    private final MedicineService medicineService;

    public MedicineController(MedicineService medicineService) {
        this.medicineService = medicineService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<MedicineSummaryResponse>>> listMedicines(
            @RequestParam(required = false) MedicineStatus status) {
        Long userId = SecurityUtils.getCurrentUserId();
        List<MedicineSummaryResponse> list = medicineService.listMedicines(userId, status);
        return ResponseEntity.ok(ApiResponse.success(list, "Medicines retrieved successfully"));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<MedicineResponse>> getMedicine(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        MedicineResponse res = medicineService.getMedicine(userId, id);
        return ResponseEntity.ok(ApiResponse.success(res, "Medicine retrieved successfully"));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<MedicineResponse>> createMedicine(
            @Valid @RequestBody CreateMedicineRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        MedicineResponse res = medicineService.createMedicine(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success(res, "Medicine created successfully"));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<MedicineResponse>> updateMedicine(
            @PathVariable Long id,
            @Valid @RequestBody UpdateMedicineRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        MedicineResponse res = medicineService.updateMedicine(userId, id, request);
        return ResponseEntity.ok(ApiResponse.success(res, "Medicine updated successfully"));
    }

    @PatchMapping("/{id}/pause")
    public ResponseEntity<ApiResponse<MedicineResponse>> pauseMedicine(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        MedicineResponse res = medicineService.pauseMedicine(userId, id);
        return ResponseEntity.ok(ApiResponse.success(res, "Medicine paused successfully"));
    }

    @PatchMapping("/{id}/resume")
    public ResponseEntity<ApiResponse<MedicineResponse>> resumeMedicine(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        MedicineResponse res = medicineService.resumeMedicine(userId, id);
        return ResponseEntity.ok(ApiResponse.success(res, "Medicine resumed successfully"));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteMedicine(@PathVariable Long id) {
        Long userId = SecurityUtils.getCurrentUserId();
        medicineService.deleteMedicine(userId, id);
        return ResponseEntity.ok(ApiResponse.messageOnly("Medicine deleted successfully"));
    }
}
