package com.dosemate.repository;

import com.dosemate.entity.Medicine;
import com.dosemate.entity.MedicineStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MedicineRepository extends JpaRepository<Medicine, Long> {

    @Query("SELECT m FROM Medicine m LEFT JOIN FETCH m.schedule LEFT JOIN FETCH m.inventory " +
           "WHERE m.user.id = :userId AND m.status <> :excludedStatus ORDER BY m.name ASC")
    List<Medicine> findByUserIdAndStatusNot(
            @Param("userId") Long userId,
            @Param("excludedStatus") MedicineStatus excludedStatus
    );

    @Query("SELECT m FROM Medicine m LEFT JOIN FETCH m.schedule LEFT JOIN FETCH m.inventory " +
           "WHERE m.user.id = :userId AND m.status = :status ORDER BY m.name ASC")
    List<Medicine> findByUserIdAndStatus(
            @Param("userId") Long userId,
            @Param("status") MedicineStatus status
    );

    @Query("SELECT m FROM Medicine m LEFT JOIN FETCH m.schedule LEFT JOIN FETCH m.inventory " +
           "WHERE m.id = :id AND m.user.id = :userId AND m.status <> :excludedStatus")
    Optional<Medicine> findByIdAndUserIdAndStatusNot(
            @Param("id") Long id,
            @Param("userId") Long userId,
            @Param("excludedStatus") MedicineStatus excludedStatus
    );

    Optional<Medicine> findByIdAndUserId(Long id, Long userId);
}
