package com.dosemate.entity;

import jakarta.persistence.*;
import java.time.Instant;

@Entity
@Table(name = "dose_records")
public class DoseRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "medicine_id")
    private Medicine medicine;

    @Column(name = "medicine_name_snapshot", nullable = false, length = 100)
    private String medicineNameSnapshot;

    @Column(name = "dosage_snapshot", nullable = false, length = 50)
    private String dosageSnapshot;

    @Column(name = "medicine_type_snapshot", nullable = false, length = 30)
    private String medicineTypeSnapshot;

    @Column(name = "scheduled_at", nullable = false)
    private Instant scheduledAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private DoseStatus status = DoseStatus.PENDING;

    @Column(name = "acted_at")
    private Instant actedAt;

    @Version
    @Column(name = "version", nullable = false)
    private Long version = 0L;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    public DoseRecord() {
    }

    @PrePersist
    protected void onCreate() {
        this.createdAt = Instant.now();
        this.updatedAt = Instant.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = Instant.now();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Medicine getMedicine() {
        return medicine;
    }

    public void setMedicine(Medicine medicine) {
        this.medicine = medicine;
    }

    public String getMedicineNameSnapshot() {
        return medicineNameSnapshot;
    }

    public void setMedicineNameSnapshot(String medicineNameSnapshot) {
        this.medicineNameSnapshot = medicineNameSnapshot;
    }

    public String getDosageSnapshot() {
        return dosageSnapshot;
    }

    public void setDosageSnapshot(String dosageSnapshot) {
        this.dosageSnapshot = dosageSnapshot;
    }

    public String getMedicineTypeSnapshot() {
        return medicineTypeSnapshot;
    }

    public void setMedicineTypeSnapshot(String medicineTypeSnapshot) {
        this.medicineTypeSnapshot = medicineTypeSnapshot;
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

    public Long getVersion() {
        return version;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
