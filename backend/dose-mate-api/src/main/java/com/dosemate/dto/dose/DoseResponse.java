package com.dosemate.dto.dose;

import com.dosemate.entity.DoseRecord;
import com.dosemate.entity.DoseStatus;
import com.dosemate.entity.MedicineType;

import java.time.Instant;

public class DoseResponse {

    private Long id;
    private Long medicineId;
    private String medicineName;
    private String dosage;
    private MedicineType type;
    private Instant scheduledAt;
    private DoseStatus status;
    private Instant actedAt;
    private String priority;

    public DoseResponse() {
    }

    public static DoseResponse fromEntity(DoseRecord record) {
        DoseResponse res = new DoseResponse();
        res.setId(record.getId());
        res.setMedicineId(record.getMedicine() != null ? record.getMedicine().getId() : null);
        res.setMedicineName(record.getMedicineNameSnapshot());
        res.setDosage(record.getDosageSnapshot());
        if (record.getMedicineTypeSnapshot() != null) {
            try {
                res.setType(MedicineType.valueOf(record.getMedicineTypeSnapshot()));
            } catch (IllegalArgumentException ignored) {
                res.setType(MedicineType.TABLET);
            }
        }
        res.setScheduledAt(record.getScheduledAt());
        res.setStatus(record.getStatus());
        res.setActedAt(record.getActedAt());
        return res;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public DoseStatus getStatus() {
        return status;
    }

    public void setStatus(DoseStatus status) {
        this.status = status;
    }

    public Instant getActedAt() {
        return actedAt;
    }

    public void setActedAt(Instant actedAt) {
        this.actedAt = actedAt;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }
}
