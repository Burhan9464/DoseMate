package com.dosemate.service;

import com.dosemate.dto.medicine.CreateMedicineRequest;
import com.dosemate.dto.medicine.InventoryDto;
import com.dosemate.dto.medicine.MedicineResponse;
import com.dosemate.dto.medicine.ScheduleDto;
import com.dosemate.entity.*;
import com.dosemate.exception.BusinessRuleException;
import com.dosemate.exception.ErrorCode;
import com.dosemate.exception.UnauthorizedResourceException;
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
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Optional;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MedicineServiceTest {

    @Mock
    private MedicineRepository medicineRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private DoseRecordRepository doseRecordRepository;

    @Mock
    private ScheduleGeneratorService scheduleGeneratorService;

    @InjectMocks
    private MedicineService medicineService;

    private User testUser;
    private CreateMedicineRequest validRequest;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("user@example.com");
        testUser.setTimezone("UTC");

        validRequest = new CreateMedicineRequest();
        validRequest.setName("Amoxicillin");
        validRequest.setDosageValue(new BigDecimal("500.00"));
        validRequest.setDosageUnit("mg");
        validRequest.setType(MedicineType.CAPSULE);
        validRequest.setStartDate(LocalDate.now());
        validRequest.setEndDate(LocalDate.now().plusDays(10));
        validRequest.setOngoing(false);

        ScheduleDto scheduleDto = new ScheduleDto(
                FrequencyMode.ONCE_DAILY,
                Set.of(DayOfWeek.MONDAY, DayOfWeek.WEDNESDAY, DayOfWeek.FRIDAY),
                Set.of(LocalTime.of(8, 0))
        );
        validRequest.setSchedule(scheduleDto);

        InventoryDto inventoryDto = new InventoryDto(30, "capsules", 5);
        validRequest.setInventory(inventoryDto);
    }

    @Test
    @DisplayName("Create medicine succeeds and triggers schedule generation")
    void testCreateMedicineSuccess() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(medicineRepository.save(any(Medicine.class))).thenAnswer(invocation -> {
            Medicine m = invocation.getArgument(0);
            m.setId(10L);
            return m;
        });

        MedicineResponse response = medicineService.createMedicine(1L, validRequest);

        assertThat(response).isNotNull();
        assertThat(response.getId()).isEqualTo(10L);
        assertThat(response.getName()).isEqualTo("Amoxicillin");
        verify(scheduleGeneratorService).generateDosesForRange(any(), any(), any(), any());
    }

    @Test
    @DisplayName("Reject schedule with multiple-daily frequency and only one time")
    void testRejectMultipleDailyWithSingleTime() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        validRequest.getSchedule().setFrequencyMode(FrequencyMode.MULTIPLE_DAILY);
        validRequest.getSchedule().setTimes(Set.of(LocalTime.of(8, 0))); // only 1 time

        assertThatThrownBy(() -> medicineService.createMedicine(1L, validRequest))
                .isInstanceOf(BusinessRuleException.class)
                .satisfies(ex -> assertThat(((BusinessRuleException) ex).getErrorCode())
                        .isEqualTo(ErrorCode.INVALID_SCHEDULE));
    }

    @Test
    @DisplayName("Reject access to another user's medicine with 403 UnauthorizedResourceException")
    void testTenantIsolationCheck() {
        User otherUser = new User();
        otherUser.setId(99L);

        Medicine medicine = new Medicine();
        medicine.setId(10L);
        medicine.setUser(otherUser);
        medicine.setStatus(MedicineStatus.ACTIVE);

        when(medicineRepository.findById(10L)).thenReturn(Optional.of(medicine));

        assertThatThrownBy(() -> medicineService.getMedicine(1L, 10L))
                .isInstanceOf(UnauthorizedResourceException.class);
    }

    @Test
    @DisplayName("Pausing medicine updates status and cancels future pending doses")
    void testPauseMedicine() {
        Medicine medicine = new Medicine();
        medicine.setId(10L);
        medicine.setUser(testUser);
        medicine.setStatus(MedicineStatus.ACTIVE);

        when(medicineRepository.findById(10L)).thenReturn(Optional.of(medicine));
        when(medicineRepository.save(any(Medicine.class))).thenAnswer(i -> i.getArgument(0));

        MedicineResponse response = medicineService.pauseMedicine(1L, 10L);

        assertThat(response.getStatus()).isEqualTo(MedicineStatus.PAUSED);
        verify(doseRecordRepository).deleteFuturePendingDoses(eq(10L), any());
    }

    @Test
    @DisplayName("Pausing already paused medicine throws MEDICINE_ALREADY_PAUSED")
    void testPauseAlreadyPausedMedicine() {
        Medicine medicine = new Medicine();
        medicine.setId(10L);
        medicine.setUser(testUser);
        medicine.setStatus(MedicineStatus.PAUSED);

        when(medicineRepository.findById(10L)).thenReturn(Optional.of(medicine));

        assertThatThrownBy(() -> medicineService.pauseMedicine(1L, 10L))
                .isInstanceOf(BusinessRuleException.class)
                .satisfies(ex -> assertThat(((BusinessRuleException) ex).getErrorCode())
                        .isEqualTo(ErrorCode.MEDICINE_ALREADY_PAUSED));
    }
}
