package com.dosemate.dto.inventory;

import jakarta.validation.constraints.Min;

public class InventoryCorrectionRequest {

    @Min(value = 0, message = "Quantity cannot be negative")
    private int quantity;

    public InventoryCorrectionRequest() {
    }

    public InventoryCorrectionRequest(int quantity) {
        this.quantity = quantity;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
}
