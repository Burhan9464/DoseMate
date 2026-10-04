package com.dosemate.dto.inventory;

import jakarta.validation.constraints.Min;

public class InventoryRefillRequest {

    @Min(value = 1, message = "Refill amount must be at least 1")
    private int refillAmount;

    public InventoryRefillRequest() {
    }

    public InventoryRefillRequest(int refillAmount) {
        this.refillAmount = refillAmount;
    }

    public int getRefillAmount() {
        return refillAmount;
    }

    public void setRefillAmount(int refillAmount) {
        this.refillAmount = refillAmount;
    }
}
