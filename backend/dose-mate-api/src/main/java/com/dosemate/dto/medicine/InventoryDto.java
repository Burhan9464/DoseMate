package com.dosemate.dto.medicine;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class InventoryDto {

    @Min(value = 0, message = "Quantity cannot be negative")
    private int quantity;

    @NotBlank(message = "Inventory unit is required")
    @Size(max = 30, message = "Unit cannot exceed 30 characters")
    private String unit;

    @Min(value = 0, message = "Low stock threshold cannot be negative")
    private int lowStockThreshold = 5;

    public InventoryDto() {
    }

    public InventoryDto(int quantity, String unit, int lowStockThreshold) {
        this.quantity = quantity;
        this.unit = unit;
        this.lowStockThreshold = lowStockThreshold;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public int getLowStockThreshold() {
        return lowStockThreshold;
    }

    public void setLowStockThreshold(int lowStockThreshold) {
        this.lowStockThreshold = lowStockThreshold;
    }
}
