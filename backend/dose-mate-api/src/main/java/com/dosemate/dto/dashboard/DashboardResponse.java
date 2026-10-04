package com.dosemate.dto.dashboard;

import com.dosemate.dto.dose.DoseResponse;
import com.dosemate.entity.MedicineType;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

public class DashboardResponse {

    private String greeting;
    private DailyProgressDto dailyProgress;
    private DoseResponse currentDose;
    private NextUpDto nextUp;
    private List<AttentionItemDto> needsAttention = new ArrayList<>();

    public DashboardResponse() {
    }

    public static class DailyProgressDto {
        private int takenDoses;
        private int totalScheduledDoses;
        private int percentage;
        private int skippedDoses;

        public DailyProgressDto() {
        }

        public DailyProgressDto(int takenDoses, int totalScheduledDoses, int percentage, int skippedDoses) {
            this.takenDoses = takenDoses;
            this.totalScheduledDoses = totalScheduledDoses;
            this.percentage = percentage;
            this.skippedDoses = skippedDoses;
        }

        public int getTakenDoses() {
            return takenDoses;
        }

        public void setTakenDoses(int takenDoses) {
            this.takenDoses = takenDoses;
        }

        public int getTotalScheduledDoses() {
            return totalScheduledDoses;
        }

        public void setTotalScheduledDoses(int totalScheduledDoses) {
            this.totalScheduledDoses = totalScheduledDoses;
        }

        public int getPercentage() {
            return percentage;
        }

        public void setPercentage(int percentage) {
            this.percentage = percentage;
        }

        public int getSkippedDoses() {
            return skippedDoses;
        }

        public void setSkippedDoses(int skippedDoses) {
            this.skippedDoses = skippedDoses;
        }
    }

    public static class NextUpDto {
        private String medicineName;
        private String dosage;
        private MedicineType type;
        private Instant scheduledAt;

        public NextUpDto() {
        }

        public NextUpDto(String medicineName, String dosage, MedicineType type, Instant scheduledAt) {
            this.medicineName = medicineName;
            this.dosage = dosage;
            this.type = type;
            this.scheduledAt = scheduledAt;
        }

        public String getMedicineName() {
            return medicineName;
        }

        public void setMedicineName(String medicineName) {
            this.medicineName = medicineName;
        }

        public String getDosage() {
            return dosage;
        }

        public void setDosage(String dosage) {
            this.dosage = dosage;
        }

        public MedicineType getType() {
            return type;
        }

        public void setType(MedicineType type) {
            this.type = type;
        }

        public Instant getScheduledAt() {
            return scheduledAt;
        }

        public void setScheduledAt(Instant scheduledAt) {
            this.scheduledAt = scheduledAt;
        }
    }

    public static class AttentionItemDto {
        private String type; // LOW_INVENTORY, MISSED_DOSE
        private Long medicineId;
        private String medicineName;
        private Integer remaining;
        private Integer threshold;
        private String message;

        public AttentionItemDto() {
        }

        public AttentionItemDto(String type, Long medicineId, String medicineName, Integer remaining, Integer threshold, String message) {
            this.type = type;
            this.medicineId = medicineId;
            this.medicineName = medicineName;
            this.remaining = remaining;
            this.threshold = threshold;
            this.message = message;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public Long getMedicineId() {
            return medicineId;
        }

        public void setMedicineId(Long medicineId) {
            this.medicineId = medicineId;
        }

        public String getMedicineName() {
            return medicineName;
        }

        public void setMedicineName(String medicineName) {
            this.medicineName = medicineName;
        }

        public Integer getRemaining() {
            return remaining;
        }

        public void setRemaining(Integer remaining) {
            this.remaining = remaining;
        }

        public Integer getThreshold() {
            return threshold;
        }

        public void setThreshold(Integer threshold) {
            this.threshold = threshold;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }
    }

    public String getGreeting() {
        return greeting;
    }

    public void setGreeting(String greeting) {
        this.greeting = greeting;
    }

    public DailyProgressDto getDailyProgress() {
        return dailyProgress;
    }

    public void setDailyProgress(DailyProgressDto dailyProgress) {
        this.dailyProgress = dailyProgress;
    }

    public DoseResponse getCurrentDose() {
        return currentDose;
    }

    public void setCurrentDose(DoseResponse currentDose) {
        this.currentDose = currentDose;
    }

    public NextUpDto getNextUp() {
        return nextUp;
    }

    public void setNextUp(NextUpDto nextUp) {
        this.nextUp = nextUp;
    }

    public List<AttentionItemDto> getNeedsAttention() {
        return needsAttention;
    }

    public void setNeedsAttention(List<AttentionItemDto> needsAttention) {
        this.needsAttention = needsAttention;
    }
}
