package com.dosemate.service;

import com.dosemate.dto.dose.DoseResponse;
import com.dosemate.dto.dose.DoseTakenResponse;
import com.dosemate.entity.*;
import com.dosemate.exception.BusinessRuleException;
import com.dosemate.exception.ErrorCode;
import com.dosemate.repository.DoseRecordRepository;
import com.dosemate.repository.InventoryRepository;
import com.dosemate.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Duration;
import java.time.Instant;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DoseServiceTest {

    @Mock
    private DoseRecordRepository doseRecordRepository;

    @Mock
    private InventoryRepository inventoryRepository;

    @Mock
    private UserRepository userRepository;

    private DoseService doseService;

    private User testUser;
    private Medicine testMedicine;
    private Inventory testInventory;
    private DoseRecord testDose;

    @BeforeEach
    void setUp() {
        doseService = new DoseService(doseRecordRepository, inventoryRepository, userRepository, 15);

        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("user@example.com");

        testMedicine = new Medicine();
        testMedicine.setId(10L);
        testMedicine.setUser(testUser);
        testMedicine.setName("Amoxicillin");
        testMedicine.setType(MedicineType.CAPSULE);

        testInventory = new Inventory();
        testInventory.setId(100L);
        testInventory.setMedicine(testMedicine);
        testInventory.setQuantity(10);
        testInventory.setUnit("capsules");
        testInventory.setLowStockThreshold(3);

        testDose = new DoseRecord();
        testDose.setId(500L);
        testDose.setUser(testUser);
        testDose.setMedicine(testMedicine);
        testDose.setMedicineNameSnapshot("Amoxicillin");
        testDose.setDosageSnapshot("500 mg");
        testDose.setMedicineTypeSnapshot("CAPSULE");
        testDose.setScheduledAt(Instant.now());
        testDose.setStatus(DoseStatus.PENDING);
    }

    @Test
    @DisplayName("Take dose marks TAKEN and decrements inventory by 1 atomically")
    void testMarkDoseTakenSuccess() {
        when(doseRecordRepository.findByIdAndUserIdForUpdate(500L, 1L)).thenReturn(Optional.of(testDose));
        when(inventoryRepository.findByMedicineIdForUpdate(10L)).thenReturn(Optional.of(testInventory));
        when(inventoryRepository.save(any(Inventory.class))).thenAnswer(i -> i.getArgument(0));
        when(doseRecordRepository.save(any(DoseRecord.class))).thenAnswer(i -> i.getArgument(0));

        DoseTakenResponse response = doseService.markDoseTaken(1L, 500L);

        assertThat(response.getDose().getStatus()).isEqualTo(DoseStatus.TAKEN);
        assertThat(response.getRemainingInventory()).isEqualTo(9);
        assertThat(response.isLowStock()).isFalse();
        assertThat(testInventory.getQuantity()).isEqualTo(9);
        verify(inventoryRepository).save(testInventory);
    }

    @Test
    @DisplayName("Idempotency: Re-taking an already TAKEN dose throws DOSE_ALREADY_COMPLETED and never double-decrements inventory")
    void testIdempotentTakeRejection() {
        testDose.setStatus(DoseStatus.TAKEN);
        when(doseRecordRepository.findByIdAndUserIdForUpdate(500L, 1L)).thenReturn(Optional.of(testDose));

        assertThatThrownBy(() -> doseService.markDoseTaken(1L, 500L))
                .isInstanceOf(BusinessRuleException.class)
                .satisfies(ex -> assertThat(((BusinessRuleException) ex).getErrorCode())
                        .isEqualTo(ErrorCode.DOSE_ALREADY_COMPLETED));

        verify(inventoryRepository, never()).save(any());
        assertThat(testInventory.getQuantity()).isEqualTo(10);
    }

    @Test
    @DisplayName("Taking dose with zero stock throws INSUFFICIENT_INVENTORY and does not allow negative inventory")
    void testZeroStockRejection() {
        testInventory.setQuantity(0);
        when(doseRecordRepository.findByIdAndUserIdForUpdate(500L, 1L)).thenReturn(Optional.of(testDose));
        when(inventoryRepository.findByMedicineIdForUpdate(10L)).thenReturn(Optional.of(testInventory));

        assertThatThrownBy(() -> doseService.markDoseTaken(1L, 500L))
                .isInstanceOf(BusinessRuleException.class)
                .satisfies(ex -> assertThat(((BusinessRuleException) ex).getErrorCode())
                        .isEqualTo(ErrorCode.INSUFFICIENT_INVENTORY));

        assertThat(testInventory.getQuantity()).isEqualTo(0);
    }

    @Test
    @DisplayName("Skip dose marks SKIPPED and leaves inventory untouched")
    void testMarkDoseSkipped() {
        when(doseRecordRepository.findByIdAndUserIdForUpdate(500L, 1L)).thenReturn(Optional.of(testDose));
        when(doseRecordRepository.save(any(DoseRecord.class))).thenAnswer(i -> i.getArgument(0));

        DoseResponse response = doseService.markDoseSkipped(1L, 500L);

        assertThat(response.getStatus()).isEqualTo(DoseStatus.SKIPPED);
        verify(inventoryRepository, never()).save(any());
        assertThat(testInventory.getQuantity()).isEqualTo(10);
    }

    @Test
    @DisplayName("Undo skip reverts dose back to PENDING within allowed window")
    void testUndoSkipSuccess() {
        testDose.setStatus(DoseStatus.SKIPPED);
        testDose.setActedAt(Instant.now().minus(Duration.ofMinutes(5)));

        when(doseRecordRepository.findByIdAndUserIdForUpdate(500L, 1L)).thenReturn(Optional.of(testDose));
        when(doseRecordRepository.save(any(DoseRecord.class))).thenAnswer(i -> i.getArgument(0));

        DoseResponse response = doseService.undoSkip(1L, 500L);

        assertThat(response.getStatus()).isEqualTo(DoseStatus.PENDING);
        assertThat(response.getActedAt()).isNull();
    }

    @Test
    @DisplayName("Undo skip after 15-minute window throws UNDO_WINDOW_EXPIRED")
    void testUndoSkipExpiredWindow() {
        testDose.setStatus(DoseStatus.SKIPPED);
        testDose.setActedAt(Instant.now().minus(Duration.ofMinutes(20))); // 20 mins ago > 15 mins window

        when(doseRecordRepository.findByIdAndUserIdForUpdate(500L, 1L)).thenReturn(Optional.of(testDose));

        assertThatThrownBy(() -> doseService.undoSkip(1L, 500L))
                .isInstanceOf(BusinessRuleException.class)
                .satisfies(ex -> assertThat(((BusinessRuleException) ex).getErrorCode())
                        .isEqualTo(ErrorCode.UNDO_WINDOW_EXPIRED));
    }
}
