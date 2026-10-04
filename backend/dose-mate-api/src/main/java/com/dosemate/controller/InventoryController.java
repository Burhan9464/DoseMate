package com.dosemate.controller;

import com.dosemate.dto.common.ApiResponse;
import com.dosemate.dto.inventory.InventoryCorrectionRequest;
import com.dosemate.dto.inventory.InventoryRefillRequest;
import com.dosemate.dto.medicine.InventoryDto;
import com.dosemate.service.InventoryService;
import com.dosemate.util.SecurityUtils;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/medicines/{medicineId}/inventory")
public class InventoryController {

    private final InventoryService inventoryService;

    public InventoryController(InventoryService inventoryService) {
        this.inventoryService = inventoryService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<InventoryDto>> getInventory(@PathVariable Long medicineId) {
        Long userId = SecurityUtils.getCurrentUserId();
        InventoryDto dto = inventoryService.getInventory(userId, medicineId);
        return ResponseEntity.ok(ApiResponse.success(dto, "Inventory retrieved successfully"));
    }

    @PatchMapping
    public ResponseEntity<ApiResponse<InventoryDto>> manualCorrection(
            @PathVariable Long medicineId,
            @Valid @RequestBody InventoryCorrectionRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        InventoryDto dto = inventoryService.manualCorrection(userId, medicineId, request.getQuantity());
        return ResponseEntity.ok(ApiResponse.success(dto, "Inventory quantity updated successfully"));
    }

    @PostMapping("/refill")
    public ResponseEntity<ApiResponse<InventoryDto>> refill(
            @PathVariable Long medicineId,
            @Valid @RequestBody InventoryRefillRequest request) {
        Long userId = SecurityUtils.getCurrentUserId();
        InventoryDto dto = inventoryService.refill(userId, medicineId, request.getRefillAmount());
        return ResponseEntity.ok(ApiResponse.success(dto, "Inventory refilled successfully"));
    }
}
