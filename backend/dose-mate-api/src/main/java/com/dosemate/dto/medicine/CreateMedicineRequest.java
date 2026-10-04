package com.dosemate.dto.medicine;

import com.dosemate.entity.MedicineType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.time.LocalDate;

public class CreateMedicineRequest {

    @NotBlank(message = "Medicine name is required")
    @Size(max = 100, message = "Medicine name cannot exceed 100 characters")
    private String name;

    @NotNull(message = "Dosage value is required")
    @DecimalMin(value = "0.01", message = "Dosage value must be greater than zero")
    private BigDecimal dosageValue;

    @NotBlank(message = "Dosage unit is required")
    @Size(max = 30, message = "Dosage unit cannot exceed 30 characters")
    private String dosageUnit;

    @NotNull(message = "Medicine type is required")
    private MedicineType type;

    @NotNull(message = "Start date is required")
    private LocalDate startDate;

    private LocalDate endDate;

    private boolean ongoing = false;

    @Size(max = 255, message = "Instructions cannot exceed 255 characters")
    private String instructions;

    @NotNull(message = "Schedule configuration is required")
    @Valid
    private ScheduleDto schedule;

    @NotNull(message = "Inventory configuration is required")
    @Valid
    private InventoryDto inventory;

    public CreateMedicineRequest() {
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
}
