package com.dosemate.service;

import com.dosemate.dto.medicine.InventoryDto;
import com.dosemate.entity.Inventory;
import com.dosemate.entity.Medicine;
import com.dosemate.exception.BusinessRuleException;
import com.dosemate.exception.ErrorCode;
import com.dosemate.exception.ResourceNotFoundException;
import com.dosemate.repository.InventoryRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class InventoryService {

    private final InventoryRepository inventoryRepository;
    private final MedicineService medicineService;

    public InventoryService(InventoryRepository inventoryRepository, MedicineService medicineService) {
        this.inventoryRepository = inventoryRepository;
        this.medicineService = medicineService;
    }

    @Transactional(readOnly = true)
    public InventoryDto getInventory(Long userId, Long medicineId) {
        Medicine medicine = medicineService.getMedicineEntityOrThrow(medicineId, userId);
        Inventory inventory = inventoryRepository.findByMedicineId(medicine.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Inventory for medicine", medicineId));

        return new InventoryDto(inventory.getQuantity(), inventory.getUnit(), inventory.getLowStockThreshold());
    }

    @Transactional
    public InventoryDto manualCorrection(Long userId, Long medicineId, int quantity) {
        if (quantity < 0) {
            throw new BusinessRuleException(ErrorCode.VALIDATION_FAILED, "Inventory quantity cannot be negative.");
        }

        Medicine medicine = medicineService.getMedicineEntityOrThrow(medicineId, userId);
        Inventory inventory = inventoryRepository.findByMedicineIdForUpdate(medicine.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Inventory for medicine", medicineId));

        inventory.setQuantity(quantity);
        Inventory saved = inventoryRepository.save(inventory);

        return new InventoryDto(saved.getQuantity(), saved.getUnit(), saved.getLowStockThreshold());
    }

    @Transactional
    public InventoryDto refill(Long userId, Long medicineId, int refillAmount) {
        if (refillAmount <= 0) {
            throw new BusinessRuleException(ErrorCode.VALIDATION_FAILED, "Refill amount must be greater than zero.");
        }

        Medicine medicine = medicineService.getMedicineEntityOrThrow(medicineId, userId);
        Inventory inventory = inventoryRepository.findByMedicineIdForUpdate(medicine.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Inventory for medicine", medicineId));

        inventory.refill(refillAmount);
        Inventory saved = inventoryRepository.save(inventory);

        return new InventoryDto(saved.getQuantity(), saved.getUnit(), saved.getLowStockThreshold());
    }
}
