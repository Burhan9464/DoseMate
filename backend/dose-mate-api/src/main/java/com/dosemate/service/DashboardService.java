package com.dosemate.service;

import com.dosemate.dto.dashboard.DashboardResponse;
import com.dosemate.dto.dose.DoseResponse;
import com.dosemate.entity.*;
import com.dosemate.exception.ResourceNotFoundException;
import com.dosemate.repository.DoseRecordRepository;
import com.dosemate.repository.MedicineRepository;
import com.dosemate.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class DashboardService {

    private final UserRepository userRepository;
    private final MedicineRepository medicineRepository;
    private final DoseRecordRepository doseRecordRepository;

    public DashboardService(
            UserRepository userRepository,
            MedicineRepository medicineRepository,
            DoseRecordRepository doseRecordRepository) {
        this.userRepository = userRepository;
        this.medicineRepository = medicineRepository;
        this.doseRecordRepository = doseRecordRepository;
    }

    @Transactional(readOnly = true)
    public DashboardResponse getDashboard(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", userId));

        ZoneId zone = resolveZone(user.getTimezone());
        ZonedDateTime userNow = ZonedDateTime.now(zone);
        LocalDate today = userNow.toLocalDate();

        Instant startOfDay = today.atStartOfDay(zone).toInstant();
        Instant endOfDay = today.atTime(LocalTime.MAX).atZone(zone).toInstant();

        // 1. Greeting
        int hour = userNow.getHour();
        String greetingPrefix;
        if (hour < 12) {
            greetingPrefix = "Good morning";
        } else if (hour < 17) {
            greetingPrefix = "Good afternoon";
        } else {
            greetingPrefix = "Good evening";
        }
        String firstName = user.getFullName().split(" ")[0];
        String greeting = String.format("%s, %s", greetingPrefix, firstName);

        // 2. Today's Doses & Progress
        List<DoseRecord> todayDoses = doseRecordRepository.findByUserIdAndScheduledAtBetweenOrderByScheduledAtAsc(
                userId, startOfDay, endOfDay
        );

        int totalScheduled = todayDoses.size();
        int takenCount = 0;
        int skippedCount = 0;
        DoseRecord currentDoseCandidate = null;

        Instant nowInstant = userNow.toInstant();

        for (DoseRecord d : todayDoses) {
            if (d.getStatus() == DoseStatus.TAKEN) {
                takenCount++;
            } else if (d.getStatus() == DoseStatus.SKIPPED) {
                skippedCount++;
            } else if (d.getStatus() == DoseStatus.PENDING && currentDoseCandidate == null) {
                currentDoseCandidate = d;
            }
        }

        int percentage = totalScheduled > 0 ? (takenCount * 100) / totalScheduled : 0;
        DashboardResponse.DailyProgressDto progress = new DashboardResponse.DailyProgressDto(
                takenCount, totalScheduled, percentage, skippedCount
        );

        // 3. Current Dose determination (Due Now -> Upcoming Today -> Next Future Dose)
        DoseResponse currentDoseResponse = null;
        if (currentDoseCandidate != null) {
            currentDoseResponse = DoseResponse.fromEntity(currentDoseCandidate);
            if (currentDoseCandidate.getScheduledAt().isBefore(nowInstant.plusSeconds(1800))) {
                currentDoseResponse.setPriority("DUE_NOW");
            } else {
                currentDoseResponse.setPriority("UPCOMING_TODAY");
            }
        } else {
            // Check next future dose after today
            Optional<DoseRecord> nextFuture = doseRecordRepository
                    .findFirstByUserIdAndScheduledAtAfterAndStatusOrderByScheduledAtAsc(userId, endOfDay, DoseStatus.PENDING);
            if (nextFuture.isPresent()) {
                currentDoseResponse = DoseResponse.fromEntity(nextFuture.get());
                currentDoseResponse.setPriority("NEXT_FUTURE_DOSE");
            }
        }

        // 4. One upcoming medicine in Next Up
        DashboardResponse.NextUpDto nextUp = null;
        Instant afterTime = currentDoseCandidate != null ? currentDoseCandidate.getScheduledAt() : nowInstant;
        Optional<DoseRecord> nextUpDose = doseRecordRepository
                .findFirstByUserIdAndScheduledAtAfterAndStatusOrderByScheduledAtAsc(userId, afterTime, DoseStatus.PENDING);

        if (nextUpDose.isPresent()) {
            DoseRecord nd = nextUpDose.get();
            MedicineType mType = MedicineType.TABLET;
            if (nd.getMedicineTypeSnapshot() != null) {
                try {
                    mType = MedicineType.valueOf(nd.getMedicineTypeSnapshot());
                } catch (IllegalArgumentException ignored) {}
            }
            nextUp = new DashboardResponse.NextUpDto(
                    nd.getMedicineNameSnapshot(),
                    nd.getDosageSnapshot(),
                    mType,
                    nd.getScheduledAt()
            );
        }

        // 5. Needs Attention (Low stock alerts, missed doses)
        List<DashboardResponse.AttentionItemDto> attentionItems = new ArrayList<>();
        List<Medicine> activeMedicines = medicineRepository.findByUserIdAndStatus(userId, MedicineStatus.ACTIVE);
        for (Medicine m : activeMedicines) {
            if (m.getInventory() != null && m.getInventory().isLowStock()) {
                attentionItems.add(new DashboardResponse.AttentionItemDto(
                        "LOW_INVENTORY",
                        m.getId(),
                        m.getName(),
                        m.getInventory().getQuantity(),
                        m.getInventory().getLowStockThreshold(),
                        String.format("Only %d %s remaining (threshold: %d)",
                                m.getInventory().getQuantity(),
                                m.getInventory().getUnit(),
                                m.getInventory().getLowStockThreshold())
                ));
            }
        }

        DashboardResponse response = new DashboardResponse();
        response.setGreeting(greeting);
        response.setDailyProgress(progress);
        response.setCurrentDose(currentDoseResponse);
        response.setNextUp(nextUp);
        response.setNeedsAttention(attentionItems);

        return response;
    }

    private ZoneId resolveZone(String timezone) {
        try {
            return (timezone != null && !timezone.isBlank()) ? ZoneId.of(timezone) : ZoneId.of("UTC");
        } catch (Exception e) {
            return ZoneId.of("UTC");
        }
    }
}
