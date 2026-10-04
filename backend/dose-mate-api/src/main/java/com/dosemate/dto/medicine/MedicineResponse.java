package com.dosemate.dto.medicine;

import com.dosemate.entity.Medicine;
import com.dosemate.entity.MedicineStatus;
import com.dosemate.entity.MedicineType;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;

public class MedicineResponse {

    private Long id;
    private String name;
    private BigDecimal dosageValue;
    private String dosageUnit;
    private MedicineType type;
    private LocalDate startDate;
    private LocalDate endDate;
    private boolean ongoing;
    private MedicineStatus status;
    private String instructions;
    private ScheduleDto schedule;
    private InventoryDto inventory;
    private Instant createdAt;
    private Instant updatedAt;

    public MedicineResponse() {
    }

    public static MedicineResponse fromEntity(Medicine medicine) {
        MedicineResponse res = new MedicineResponse();
        res.setId(medicine.getId());
        res.setName(medicine.getName());
        res.setDosageValue(medicine.getDosageValue());
        res.setDosageUnit(medicine.getDosageUnit());
        res.setType(medicine.getType());
        res.setStartDate(medicine.getStartDate());
        res.setEndDate(medicine.getEndDate());
        res.setOngoing(medicine.isOngoing());
        res.setStatus(medicine.getStatus());
        res.setInstructions(medicine.getInstructions());
        res.setCreatedAt(medicine.getCreatedAt());
        res.setUpdatedAt(medicine.getUpdatedAt());

        if (medicine.getSchedule() != null) {
            res.setSchedule(new ScheduleDto(
                    medicine.getSchedule().getFrequencyMode(),
                    medicine.getSchedule().getDays(),
                    medicine.getSchedule().getTimes()
            ));
        }

        if (medicine.getInventory() != null) {
            res.setInventory(new InventoryDto(
                    medicine.getInventory().getQuantity(),
                    medicine.getInventory().getUnit(),
                    medicine.getInventory().getLowStockThreshold()
            ));
        }

        return res;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BigDecimal getDosageValue() {
        return dosageValue;
    }

    public void setDosageValue(BigDecimal dosageValue) {
        this.dosageValue = dosageValue;
    }

    public String getDosageUnit() {
        return dosageUnit;
    }

    public void setDosageUnit(String dosageUnit) {
        this.dosageUnit = dosageUnit;
    }

    public MedicineType getType() {
        return type;
    }

    public void setType(MedicineType type) {
        this.type = type;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public boolean isOngoing() {
        return ongoing;
    }

    public void setOngoing(boolean ongoing) {
        this.ongoing = ongoing;
    }

    public MedicineStatus getStatus() {
        return status;
    }

    public void setStatus(MedicineStatus status) {
        this.status = status;
    }

    public String getInstructions() {
        return instructions;
    }

    public void setInstructions(String instructions) {
        this.instructions = instructions;
    }

    public ScheduleDto getSchedule() {
        return schedule;
    }

    public void setSchedule(ScheduleDto schedule) {
        this.schedule = schedule;
    }

    public InventoryDto getInventory() {
        return inventory;
    }

    public void setInventory(InventoryDto inventory) {
        this.inventory = inventory;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }
}
