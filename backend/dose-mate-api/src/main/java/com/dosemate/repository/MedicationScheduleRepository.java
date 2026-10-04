package com.dosemate.repository;

import com.dosemate.entity.MedicationSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MedicationScheduleRepository extends JpaRepository<MedicationSchedule, Long> {

    Optional<MedicationSchedule> findByMedicineId(Long medicineId);
}
