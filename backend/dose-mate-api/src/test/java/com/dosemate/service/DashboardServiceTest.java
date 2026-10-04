package com.dosemate.service;

import com.dosemate.dto.dashboard.DashboardResponse;
import com.dosemate.entity.*;
import com.dosemate.repository.DoseRecordRepository;
import com.dosemate.repository.MedicineRepository;
import com.dosemate.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DashboardServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private MedicineRepository medicineRepository;

    @Mock
    private DoseRecordRepository doseRecordRepository;

    @InjectMocks
    private DashboardService dashboardService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setFullName("John Smith");
        testUser.setEmail("john@example.com");
        testUser.setTimezone("UTC");
    }

    @Test
    @DisplayName("Dashboard calculates daily progress: taken counts as completed, skipped does not")
    void testDailyProgressCalculation() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));

        Medicine medicine = new Medicine();
        medicine.setId(10L);
        medicine.setName("Aspirin");
        medicine.setDosageValue(new BigDecimal("100"));
        medicine.setDosageUnit("mg");
        medicine.setType(MedicineType.TABLET);

        DoseRecord dose1 = new DoseRecord();
        dose1.setId(1L);
        dose1.setMedicine(medicine);
        dose1.setMedicineNameSnapshot("Aspirin");
        dose1.setDosageSnapshot("100 mg");
        dose1.setMedicineTypeSnapshot("TABLET");
        dose1.setScheduledAt(Instant.now());
        dose1.setStatus(DoseStatus.TAKEN);

        DoseRecord dose2 = new DoseRecord();
        dose2.setId(2L);
        dose2.setMedicine(medicine);
        dose2.setMedicineNameSnapshot("Aspirin");
        dose2.setDosageSnapshot("100 mg");
        dose2.setMedicineTypeSnapshot("TABLET");
        dose2.setScheduledAt(Instant.now().plusSeconds(3600));
        dose2.setStatus(DoseStatus.SKIPPED);

        DoseRecord dose3 = new DoseRecord();
        dose3.setId(3L);
        dose3.setMedicine(medicine);
        dose3.setMedicineNameSnapshot("Aspirin");
        dose3.setDosageSnapshot("100 mg");
        dose3.setMedicineTypeSnapshot("TABLET");
        dose3.setScheduledAt(Instant.now().plusSeconds(7200));
        dose3.setStatus(DoseStatus.PENDING);

        when(doseRecordRepository.findByUserIdAndScheduledAtBetweenOrderByScheduledAtAsc(eq(1L), any(), any()))
                .thenReturn(List.of(dose1, dose2, dose3));

        when(medicineRepository.findByUserIdAndStatus(1L, MedicineStatus.ACTIVE))
                .thenReturn(List.of(medicine));

        DashboardResponse response = dashboardService.getDashboard(1L);

        assertThat(response.getGreeting()).contains("John");
        assertThat(response.getDailyProgress().getTotalScheduledDoses()).isEqualTo(3);
        assertThat(response.getDailyProgress().getTakenDoses()).isEqualTo(1);
        assertThat(response.getDailyProgress().getSkippedDoses()).isEqualTo(1);
        // 1 out of 3 = 33%
        assertThat(response.getDailyProgress().getPercentage()).isEqualTo(33);
        assertThat(response.getCurrentDose()).isNotNull();
        assertThat(response.getCurrentDose().getId()).isEqualTo(3L);
    }

    @Test
    @DisplayName("Dashboard includes Needs Attention item when inventory is below low stock threshold")
    void testLowStockNeedsAttention() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(doseRecordRepository.findByUserIdAndScheduledAtBetweenOrderByScheduledAtAsc(eq(1L), any(), any()))
                .thenReturn(List.of());

        Medicine medicine = new Medicine();
        medicine.setId(10L);
        medicine.setName("Ibuprofen");

        Inventory inventory = new Inventory();
        inventory.setQuantity(2);
        inventory.setUnit("tablets");
        inventory.setLowStockThreshold(5); // 2 <= 5 -> low stock!
        medicine.setInventory(inventory);

        when(medicineRepository.findByUserIdAndStatus(1L, MedicineStatus.ACTIVE))
                .thenReturn(List.of(medicine));

        DashboardResponse response = dashboardService.getDashboard(1L);

        assertThat(response.getNeedsAttention()).hasSize(1);
        assertThat(response.getNeedsAttention().get(0).getType()).isEqualTo("LOW_INVENTORY");
        assertThat(response.getNeedsAttention().get(0).getMedicineName()).isEqualTo("Ibuprofen");
        assertThat(response.getNeedsAttention().get(0).getRemaining()).isEqualTo(2);
    }
}
