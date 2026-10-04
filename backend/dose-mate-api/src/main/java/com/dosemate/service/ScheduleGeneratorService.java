package com.dosemate.service;

import com.dosemate.entity.DoseRecord;
import com.dosemate.entity.DoseStatus;
import com.dosemate.entity.MedicationSchedule;
import com.dosemate.entity.Medicine;
import com.dosemate.repository.DoseRecordRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.*;
import java.util.ArrayList;
import java.util.List;

@Service
public class ScheduleGeneratorService {

    private final DoseRecordRepository doseRecordRepository;

    public ScheduleGeneratorService(DoseRecordRepository doseRecordRepository) {
        this.doseRecordRepository = doseRecordRepository;
    }

    @Transactional
    public List<DoseRecord> generateDosesForRange(
            Medicine medicine,
            LocalDate rangeStart,
            LocalDate rangeEnd,
            ZoneId userZone) {

        MedicationSchedule schedule = medicine.getSchedule();
        if (schedule == null || schedule.getDays().isEmpty() || schedule.getTimes().isEmpty()) {
            return List.of();
        }

        LocalDate effectiveStart = rangeStart.isBefore(medicine.getStartDate())
                ? medicine.getStartDate()
                : rangeStart;

        LocalDate effectiveEnd = rangeEnd;
        if (!medicine.isOngoing() && medicine.getEndDate() != null && rangeEnd.isAfter(medicine.getEndDate())) {
            effectiveEnd = medicine.getEndDate();
        }

        if (effectiveStart.isAfter(effectiveEnd)) {
            return List.of();
        }

        List<DoseRecord> newDoses = new ArrayList<>();
        LocalDate current = effectiveStart;

        while (!current.isAfter(effectiveEnd)) {
            DayOfWeek day = current.getDayOfWeek();
            if (schedule.getDays().contains(day)) {
                for (LocalTime time : schedule.getTimes()) {
                    ZonedDateTime zdt = ZonedDateTime.of(current, time, userZone);
                    Instant scheduledAt = zdt.toInstant();

                    if (!doseRecordRepository.existsByMedicineIdAndScheduledAt(medicine.getId(), scheduledAt)) {
                        DoseRecord dose = new DoseRecord();
                        dose.setUser(medicine.getUser());
                        dose.setMedicine(medicine);
                        dose.setMedicineNameSnapshot(medicine.getName());
                        dose.setDosageSnapshot(String.format("%s %s", medicine.getDosageValue().stripTrailingZeros().toPlainString(), medicine.getDosageUnit()));
                        dose.setMedicineTypeSnapshot(medicine.getType().name());
                        dose.setScheduledAt(scheduledAt);
                        dose.setStatus(DoseStatus.PENDING);
                        newDoses.add(dose);
                    }
                }
            }
            current = current.plusDays(1);
        }

        if (!newDoses.isEmpty()) {
            return doseRecordRepository.saveAll(newDoses);
        }
        return List.of();
    }
}
