-- =============================================================================
-- DoseMate Relational Database Schema (MySQL 8.0+)
-- Character Set: utf8mb4 | Collation: utf8mb4_0900_ai_ci
-- =============================================================================

CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    timezone VARCHAR(50) NOT NULL DEFAULT 'UTC',
    onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE,
    guide_completed BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT chk_users_gender CHECK (gender IN ('MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS medicines (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    dosage_value DECIMAL(10, 2) NOT NULL,
    dosage_unit VARCHAR(30) NOT NULL,
    type VARCHAR(30) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    ongoing BOOLEAN NOT NULL DEFAULT FALSE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    instructions VARCHAR(255) NULL,
    version BIGINT NOT NULL DEFAULT 0,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT fk_medicines_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_medicines_dosage CHECK (dosage_value > 0),
    CONSTRAINT chk_medicines_type CHECK (type IN ('TABLET', 'CAPSULE', 'SYRUP', 'INJECTION', 'DROPS', 'CREAM', 'SUPPLEMENT')),
    CONSTRAINT chk_medicines_status CHECK (status IN ('ACTIVE', 'PAUSED', 'DELETED')),
    INDEX idx_medicines_user_status (user_id, status),
    INDEX idx_medicines_user_name (user_id, name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS medication_schedules (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    medicine_id BIGINT NOT NULL UNIQUE,
    frequency_mode VARCHAR(30) NOT NULL,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT fk_schedules_medicine FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE,
    CONSTRAINT chk_schedules_mode CHECK (frequency_mode IN ('ONCE_DAILY', 'MULTIPLE_DAILY', 'CUSTOM'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS schedule_days (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    schedule_id BIGINT NOT NULL,
    day_of_week VARCHAR(15) NOT NULL,
    CONSTRAINT fk_sched_days_schedule FOREIGN KEY (schedule_id) REFERENCES medication_schedules(id) ON DELETE CASCADE,
    CONSTRAINT uq_schedule_day UNIQUE (schedule_id, day_of_week),
    CONSTRAINT chk_day_of_week CHECK (day_of_week IN ('MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS schedule_times (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    schedule_id BIGINT NOT NULL,
    dose_time TIME NOT NULL,
    CONSTRAINT fk_sched_times_schedule FOREIGN KEY (schedule_id) REFERENCES medication_schedules(id) ON DELETE CASCADE,
    CONSTRAINT uq_schedule_time UNIQUE (schedule_id, dose_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS inventory (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    medicine_id BIGINT NOT NULL UNIQUE,
    quantity INT NOT NULL,
    unit VARCHAR(30) NOT NULL,
    low_stock_threshold INT NOT NULL DEFAULT 5,
    version BIGINT NOT NULL DEFAULT 0,
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT fk_inventory_medicine FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE CASCADE,
    CONSTRAINT chk_inventory_quantity CHECK (quantity >= 0),
    CONSTRAINT chk_inventory_threshold CHECK (low_stock_threshold >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS dose_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    medicine_id BIGINT NULL,
    medicine_name_snapshot VARCHAR(100) NOT NULL,
    dosage_snapshot VARCHAR(50) NOT NULL,
    medicine_type_snapshot VARCHAR(30) NOT NULL,
    scheduled_at DATETIME(6) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    acted_at DATETIME(6) NULL,
    version BIGINT NOT NULL DEFAULT 0,
    created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    CONSTRAINT fk_dose_records_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_dose_records_medicine FOREIGN KEY (medicine_id) REFERENCES medicines(id) ON DELETE SET NULL,
    CONSTRAINT chk_dose_status CHECK (status IN ('PENDING', 'TAKEN', 'SKIPPED', 'MISSED')),
    CONSTRAINT uq_medicine_scheduled UNIQUE (medicine_id, scheduled_at),
    INDEX idx_doses_user_scheduled (user_id, scheduled_at),
    INDEX idx_doses_user_status (user_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
