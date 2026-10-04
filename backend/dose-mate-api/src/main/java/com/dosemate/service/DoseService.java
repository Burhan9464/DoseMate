package com.dosemate.service;

import com.dosemate.dto.dose.DoseHistoryPageResponse;
import com.dosemate.dto.dose.DoseResponse;
import com.dosemate.dto.dose.DoseTakenResponse;
import com.dosemate.entity.DoseRecord;
import com.dosemate.entity.DoseStatus;
import com.dosemate.entity.Inventory;
import com.dosemate.entity.User;
import com.dosemate.exception.BusinessRuleException;
import com.dosemate.exception.ErrorCode;
import com.dosemate.exception.ResourceNotFoundException;
import com.dosemate.repository.DoseRecordRepository;
import com.dosemate.repository.InventoryRepository;
import com.dosemate.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.*;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class DoseService {

    private static final Logger log = LoggerFactory.getLogger(DoseService.class);

    private final DoseRecordRepository doseRecordRepository;
    private final InventoryRepository inventoryRepository;
    private final UserRepository userRepository;
    private final long undoWindowMinutes;

    public DoseService(
            DoseRecordRepository doseRecordRepository,
            InventoryRepository inventoryRepository,
            UserRepository userRepository,
            @Value("${dosemate.dose.undo-window-minutes:15}") long undoWindowMinutes) {
        this.doseRecordRepository = doseRecordRepository;
        this.inventoryRepository = inventoryRepository;
        this.userRepository = userRepository;
        this.undoWindowMinutes = undoWindowMinutes;
    }

    @Transactional(readOnly = true)
    public List<DoseResponse> getTodayDoses(Long userId) {
        User user = getUserOrThrow(userId);
        ZoneId zone = resolveZone(user.getTimezone());
        LocalDate today = LocalDate.now(zone);

        Instant startOfDay = today.atStartOfDay(zone).toInstant();
        Instant endOfDay = today.atTime(LocalTime.MAX).atZone(zone).toInstant();

        List<DoseRecord> records = doseRecordRepository.findByUserIdAndScheduledAtBetweenOrderByScheduledAtAsc(
                userId, startOfDay, endOfDay
        );

        Instant now = Instant.now();
        return records.stream().map(record -> {
            DoseResponse res = DoseResponse.fromEntity(record);
            if (record.getStatus() == DoseStatus.PENDING) {
                if (record.getScheduledAt().isBefore(now.plusSeconds(1800))) {
                    res.setPriority("DUE_NOW");
                } else {
                    res.setPriority("UPCOMING_TODAY");
                }
            } else {
                res.setPriority("COMPLETED");
            }
            return res;
        }).collect(Collectors.toList());
    }

    @Transactional
    public DoseTakenResponse markDoseTaken(Long userId, Long doseId) {
        DoseRecord dose = doseRecordRepository.findByIdAndUserIdForUpdate(doseId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Dose", doseId));

        if (dose.getStatus() == DoseStatus.TAKEN) {
            throw new BusinessRuleException(ErrorCode.DOSE_ALREADY_COMPLETED);
        }

        if (dose.getStatus() != DoseStatus.PENDING && dose.getStatus() != DoseStatus.SKIPPED) {
            throw new BusinessRuleException(ErrorCode.DOSE_NOT_PENDING, "Dose cannot be marked taken from current status: " + dose.getStatus());
        }

        int remainingInventory = 0;
        boolean isLowStock = false;

        // Decrement inventory transactionally
        if (dose.getMedicine() != null) {
            Long medicineId = dose.getMedicine().getId();
            Inventory inventory = inventoryRepository.findByMedicineIdForUpdate(medicineId)
                    .orElse(null);

            if (inventory != null) {
                if (inventory.getQuantity() <= 0) {
                    throw new BusinessRuleException(
                            ErrorCode.INSUFFICIENT_INVENTORY,
                            "Cannot take dose: medication stock is exhausted (0 remaining)."
                    );
                }
                inventory.decrement();
                Inventory savedInv = inventoryRepository.save(inventory);
                remainingInventory = savedInv.getQuantity();
                isLowStock = savedInv.isLowStock();
            }
        }

        dose.setStatus(DoseStatus.TAKEN);
        dose.setActedAt(Instant.now());
        DoseRecord savedDose = doseRecordRepository.save(dose);

        return new DoseTakenResponse(DoseResponse.fromEntity(savedDose), remainingInventory, isLowStock);
    }

    @Transactional
    public DoseResponse markDoseSkipped(Long userId, Long doseId) {
        DoseRecord dose = doseRecordRepository.findByIdAndUserIdForUpdate(doseId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Dose", doseId));

        if (dose.getStatus() == DoseStatus.TAKEN) {
            throw new BusinessRuleException(ErrorCode.DOSE_ALREADY_COMPLETED, "Cannot skip a dose that has already been taken.");
        }

        if (dose.getStatus() == DoseStatus.SKIPPED) {
            return DoseResponse.fromEntity(dose);
        }

        dose.setStatus(DoseStatus.SKIPPED);
        dose.setActedAt(Instant.now());
        DoseRecord savedDose = doseRecordRepository.save(dose);

        return DoseResponse.fromEntity(savedDose);
    }

    @Transactional
    public DoseResponse undoSkip(Long userId, Long doseId) {
        DoseRecord dose = doseRecordRepository.findByIdAndUserIdForUpdate(doseId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Dose", doseId));

        if (dose.getStatus() != DoseStatus.SKIPPED) {
            throw new BusinessRuleException(ErrorCode.DOSE_NOT_PENDING, "Only skipped doses can be undone.");
        }

        if (dose.getActedAt() != null) {
            Duration elapsed = Duration.between(dose.getActedAt(), Instant.now());
            if (elapsed.toMinutes() > undoWindowMinutes) {
                throw new BusinessRuleException(ErrorCode.UNDO_WINDOW_EXPIRED);
            }
        }

        dose.setStatus(DoseStatus.PENDING);
        dose.setActedAt(null);
        DoseRecord savedDose = doseRecordRepository.save(dose);

        return DoseResponse.fromEntity(savedDose);
    }

    @Transactional(readOnly = true)
    public DoseHistoryPageResponse getHistory(
            Long userId,
            DoseStatus status,
            String search,
            Instant startDate,
            Instant endDate,
            int page,
            int size) {

        Pageable pageable = PageRequest.of(page, Math.min(size, 100));
        String searchParam = (search != null && !search.isBlank()) ? search.trim() : null;

        Page<DoseRecord> resultPage = doseRecordRepository.searchHistory(
                userId, status, searchParam, startDate, endDate, pageable
        );

        List<DoseResponse> content = resultPage.getContent().stream()
                .map(DoseResponse::fromEntity)
                .collect(Collectors.toList());

        return new DoseHistoryPageResponse(
                content,
                resultPage.getNumber(),
                resultPage.getSize(),
                resultPage.getTotalElements(),
                resultPage.getTotalPages(),
                resultPage.isLast()
        );
    }

    @Scheduled(cron = "0 0 * * * *") // Run hourly
    @Transactional
    public void sweepMissedDoses() {
        Instant cutoff = Instant.now().minus(Duration.ofHours(3));
        int updated = doseRecordRepository.markOverduePendingDosesAsMissed(cutoff);
        if (updated > 0) {
            log.info("Overdue dose sweep: marked {} doses as MISSED (cutoff: {})", updated, cutoff);
        }
    }

    private User getUserOrThrow(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));
    }

    private ZoneId resolveZone(String timezone) {
        try {
            return (timezone != null && !timezone.isBlank()) ? ZoneId.of(timezone) : ZoneId.of("UTC");
        } catch (Exception e) {
            return ZoneId.of("UTC");
        }
    }
}
