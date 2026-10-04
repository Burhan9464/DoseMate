package com.dosemate.dto.dose;

public class DoseTakenResponse {

    private DoseResponse dose;
    private int remainingInventory;
    private boolean isLowStock;

    public DoseTakenResponse() {
    }

    public DoseTakenResponse(DoseResponse dose, int remainingInventory, boolean isLowStock) {
        this.dose = dose;
        this.remainingInventory = remainingInventory;
        this.isLowStock = isLowStock;
    }

    public DoseResponse getDose() {
        return dose;
    }

    public void setDose(DoseResponse dose) {
        this.dose = dose;
    }

    public int getRemainingInventory() {
        return remainingInventory;
    }

    public void setRemainingInventory(int remainingInventory) {
        this.remainingInventory = remainingInventory;
    }

    public boolean isLowStock() {
        return isLowStock;
    }

    public void setLowStock(boolean lowStock) {
        isLowStock = lowStock;
    }
}
