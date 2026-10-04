package com.dosemate.service;

import com.dosemate.dto.medicine.*;
import com.dosemate.entity.*;
import com.dosemate.exception.BusinessRuleException;
import com.dosemate.exception.ErrorCode;
import com.dosemate.exception.ResourceNotFoundException;
import com.dosemate.exception.UnauthorizedResourceException;
import com.dosemate.repository.DoseRecordRepository;
import com.dosemate.repository.MedicineRepository;
import com.dosemate.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class MedicineService {

    private final MedicineRepository medicineRepository;
    private final UserRepository userRepository;
    private final DoseRecordRepository doseRecordRepository;
    private final ScheduleGeneratorService scheduleGeneratorService;

    public MedicineService(
            MedicineRepository medicineRepository,
            UserRepository userRepository,
            DoseRecordRepository doseRecordRepository,
            ScheduleGeneratorService scheduleGeneratorService) {
        this.medicineRepository = medicineRepository;
        this.userRepository = userRepository;
        this.doseRecordRepository = doseRecordRepository;
        this.scheduleGeneratorService = scheduleGeneratorService;
    }

    @Transactional
    public MedicineResponse createMedicine(Long userId, CreateMedicineRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));

        validateScheduleAndDates(request.getStartDate(), request.getEndDate(), request.isOngoing(), request.getSchedule());

        Medicine medicine = new Medicine();
        medicine.setUser(user);
        medicine.setName(request.getName().trim());
        medicine.setDosageValue(request.getDosageValue());
        medicine.setDosageUnit(request.getDosageUnit().trim());
        medicine.setType(request.getType());
        medicine.setStartDate(request.getStartDate());
        medicine.setOngoing(request.isOngoing());
        medicine.setEndDate(request.isOngoing() ? null : request.getEndDate());
        medicine.setInstructions(request.getInstructions() != null ? request.getInstructions().trim() : null);
        medicine.setStatus(MedicineStatus.ACTIVE);

        // Schedule
        MedicationSchedule schedule = new MedicationSchedule();
        schedule.setFrequencyMode(request.getSchedule().getFrequencyMode());
        schedule.setDays(request.getSchedule().getDays());
        schedule.setTimes(request.getSchedule().getTimes());
        medicine.setSchedule(schedule);

        // Inventory
        Inventory inventory = new Inventory();
        inventory.setQuantity(request.getInventory().getQuantity());
        inventory.setUnit(request.getInventory().getUnit().trim());
        inventory.setLowStockThreshold(request.getInventory().getLowStockThreshold());
        medicine.setInventory(inventory);

        Medicine savedMedicine = medicineRepository.save(medicine);

        // Generate immediate upcoming doses for the next 7 days
        ZoneId userZone = resolveZone(user.getTimezone());
        LocalDate today = LocalDate.now(userZone);
        scheduleGeneratorService.generateDosesForRange(savedMedicine, today, today.plusDays(7), userZone);

        return MedicineResponse.fromEntity(savedMedicine);
    }

    @Transactional
    public MedicineResponse updateMedicine(Long userId, Long medicineId, UpdateMedicineRequest request) {
        Medicine medicine = getMedicineEntityOrThrow(medicineId, userId);

        validateScheduleAndDates(request.getStartDate(), request.getEndDate(), request.isOngoing(), request.getSchedule());

        medicine.setName(request.getName().trim());
        medicine.setDosageValue(request.getDosageValue());
        medicine.setDosageUnit(request.getDosageUnit().trim());
        medicine.setType(request.getType());
        medicine.setStartDate(request.getStartDate());
        medicine.setOngoing(request.isOngoing());
        medicine.setEndDate(request.isOngoing() ? null : request.getEndDate());
        medicine.setInstructions(request.getInstructions() != null ? request.getInstructions().trim() : null);

        // Update schedule
        MedicationSchedule schedule = medicine.getSchedule();
        if (schedule == null) {
            schedule = new MedicationSchedule();
            medicine.setSchedule(schedule);
        }
        schedule.setFrequencyMode(request.getSchedule().getFrequencyMode());
        schedule.getDays().clear();
        schedule.getDays().addAll(request.getSchedule().getDays());
        schedule.getTimes().clear();
        schedule.getTimes().addAll(request.getSchedule().getTimes());

        // Update inventory config if provided
        if (request.getInventory() != null && medicine.getInventory() != null) {
            medicine.getInventory().setUnit(request.getInventory().getUnit().trim());
            medicine.getInventory().setLowStockThreshold(request.getInventory().getLowStockThreshold());
        }

        Medicine updatedMedicine = medicineRepository.save(medicine);

        // Cancel future pending doses and reconcile new schedule
        Instant now = Instant.now();
        doseRecordRepository.deleteFuturePendingDoses(medicineId, now);

        if (updatedMedicine.getStatus() == MedicineStatus.ACTIVE) {
            ZoneId userZone = resolveZone(medicine.getUser().getTimezone());
            LocalDate today = LocalDate.now(userZone);
            scheduleGeneratorService.generateDosesForRange(updatedMedicine, today, today.plusDays(7), userZone);
        }

        return MedicineResponse.fromEntity(updatedMedicine);
    }

    @Transactional(readOnly = true)
    public MedicineResponse getMedicine(Long userId, Long medicineId) {
        Medicine medicine = getMedicineEntityOrThrow(medicineId, userId);
        return MedicineResponse.fromEntity(medicine);
    }

    @Transactional(readOnly = true)
    public List<MedicineSummaryResponse> listMedicines(Long userId, MedicineStatus status) {
        List<Medicine> medicines;
        if (status != null) {
            medicines = medicineRepository.findByUserIdAndStatus(userId, status);
        } else {
            medicines = medicineRepository.findByUserIdAndStatusNot(userId, MedicineStatus.DELETED);
        }
        return medicines.stream()
                .map(MedicineSummaryResponse::fromEntity)
                .collect(Collectors.toList());
    }

    @Transactional
    public MedicineResponse pauseMedicine(Long userId, Long medicineId) {
        Medicine medicine = getMedicineEntityOrThrow(medicineId, userId);
        if (medicine.getStatus() == MedicineStatus.PAUSED) {
            throw new BusinessRuleException(ErrorCode.MEDICINE_ALREADY_PAUSED);
        }

        medicine.setStatus(MedicineStatus.PAUSED);
        Medicine saved = medicineRepository.save(medicine);

        // Cancel future pending doses from now onwards
        doseRecordRepository.deleteFuturePendingDoses(medicineId, Instant.now());

        return MedicineResponse.fromEntity(saved);
    }

    @Transactional
    public MedicineResponse resumeMedicine(Long userId, Long medicineId) {
        Medicine medicine = getMedicineEntityOrThrow(medicineId, userId);
        if (medicine.getStatus() == MedicineStatus.ACTIVE) {
            throw new BusinessRuleException(ErrorCode.MEDICINE_ALREADY_ACTIVE);
        }

        medicine.setStatus(MedicineStatus.ACTIVE);
        Medicine saved = medicineRepository.save(medicine);

        // Reconcile and generate future doses starting from today
        ZoneId userZone = resolveZone(medicine.getUser().getTimezone());
        LocalDate today = LocalDate.now(userZone);
        scheduleGeneratorService.generateDosesForRange(saved, today, today.plusDays(7), userZone);

        return MedicineResponse.fromEntity(saved);
    }

    @Transactional
    public void deleteMedicine(Long userId, Long medicineId) {
        Medicine medicine = getMedicineEntityOrThrow(medicineId, userId);

        medicine.setStatus(MedicineStatus.DELETED);
        medicineRepository.save(medicine);

        // Cancel future pending doses; past taken/skipped records are preserved for history
        doseRecordRepository.deleteFuturePendingDoses(medicineId, Instant.now());
    }

    public Medicine getMedicineEntityOrThrow(Long medicineId, Long userId) {
        Medicine medicine = medicineRepository.findById(medicineId)
                .orElseThrow(() -> new ResourceNotFoundException("Medicine", medicineId));

        if (!medicine.getUser().getId().equals(userId)) {
            throw new UnauthorizedResourceException();
        }

        if (medicine.getStatus() == MedicineStatus.DELETED) {
            throw new ResourceNotFoundException("Medicine", medicineId);
        }

        return medicine;
    }

    private void validateScheduleAndDates(LocalDate startDate, LocalDate endDate, boolean ongoing, ScheduleDto schedule) {
        if (!ongoing) {
            if (endDate == null) {
                throw new BusinessRuleException(ErrorCode.VALIDATION_FAILED, "End date is required for non-ongoing medication.");
            }
            if (endDate.isBefore(startDate)) {
                throw new BusinessRuleException(ErrorCode.VALIDATION_FAILED, "End date cannot be before start date.");
            }
        }

        if (schedule == null || schedule.getDays() == null || schedule.getDays().isEmpty()) {
            throw new BusinessRuleException(ErrorCode.INVALID_SCHEDULE, "At least one day of the week must be selected.");
        }

        if (schedule.getTimes() == null || schedule.getTimes().isEmpty()) {
            throw new BusinessRuleException(ErrorCode.INVALID_SCHEDULE, "At least one medication time must be specified.");
        }

        if (schedule.getFrequencyMode() == FrequencyMode.MULTIPLE_DAILY && schedule.getTimes().size() < 2) {
            throw new BusinessRuleException(ErrorCode.INVALID_SCHEDULE, "Multiple times per day requires at least two distinct times.");
        }
    }

    private ZoneId resolveZone(String timezone) {
        try {
            return (timezone != null && !timezone.isBlank()) ? ZoneId.of(timezone) : ZoneId.of("UTC");
        } catch (Exception e) {
            return ZoneId.of("UTC");
        }
    }
}
