package com.dosemate.dto.medicine;

import com.dosemate.entity.Medicine;
import com.dosemate.entity.MedicineStatus;
import com.dosemate.entity.MedicineType;

import java.math.BigDecimal;
import java.time.LocalTime;
import java.util.Set;

public class MedicineSummaryResponse {

    private Long id;
    private String name;
    private BigDecimal dosageValue;
    private String dosageUnit;
    private MedicineType type;
    private MedicineStatus status;
    private boolean ongoing;
    private int remainingQuantity;
    private String inventoryUnit;
    private boolean isLowStock;
    private Set<LocalTime> doseTimes;

    public MedicineSummaryResponse() {
    }

    public static MedicineSummaryResponse fromEntity(Medicine medicine) {
        MedicineSummaryResponse res = new MedicineSummaryResponse();
        res.setId(medicine.getId());
        res.setName(medicine.getName());
        res.setDosageValue(medicine.getDosageValue());
        res.setDosageUnit(medicine.getDosageUnit());
        res.setType(medicine.getType());
        res.setStatus(medicine.getStatus());
        res.setOngoing(medicine.isOngoing());

        if (medicine.getInventory() != null) {
            res.setRemainingQuantity(medicine.getInventory().getQuantity());
            res.setInventoryUnit(medicine.getInventory().getUnit());
            res.setLowStock(medicine.getInventory().isLowStock());
        }

        if (medicine.getSchedule() != null) {
            res.setDoseTimes(medicine.getSchedule().getTimes());
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

    public MedicineStatus getStatus() {
        return status;
    }

    public void setStatus(MedicineStatus status) {
        this.status = status;
    }

    public boolean isOngoing() {
        return ongoing;
    }

    public void setOngoing(boolean ongoing) {
        this.ongoing = ongoing;
    }

    public int getRemainingQuantity() {
        return remainingQuantity;
    }

    public void setRemainingQuantity(int remainingQuantity) {
        this.remainingQuantity = remainingQuantity;
    }

    public String getInventoryUnit() {
        return inventoryUnit;
    }

    public void setInventoryUnit(String inventoryUnit) {
        this.inventoryUnit = inventoryUnit;
    }

    public boolean isLowStock() {
        return isLowStock;
    }

    public void setLowStock(boolean lowStock) {
        isLowStock = lowStock;
    }

    public Set<LocalTime> getDoseTimes() {
        return doseTimes;
    }

    public void setDoseTimes(Set<LocalTime> doseTimes) {
        this.doseTimes = doseTimes;
    }
}
