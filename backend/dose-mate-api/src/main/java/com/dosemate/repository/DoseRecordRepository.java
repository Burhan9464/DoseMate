package com.dosemate.repository;

import com.dosemate.entity.DoseRecord;
import com.dosemate.entity.DoseStatus;
import jakarta.persistence.LockModeType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

@Repository
public interface DoseRecordRepository extends JpaRepository<DoseRecord, Long> {

    Optional<DoseRecord> findByIdAndUserId(Long id, Long userId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT d FROM DoseRecord d WHERE d.id = :id AND d.user.id = :userId")
    Optional<DoseRecord> findByIdAndUserIdForUpdate(@Param("id") Long id, @Param("userId") Long userId);

    List<DoseRecord> findByUserIdAndScheduledAtBetweenOrderByScheduledAtAsc(
            Long userId,
            Instant start,
            Instant end
    );

    @Query("SELECT d FROM DoseRecord d WHERE d.user.id = :userId " +
           "AND (:status IS NULL OR d.status = :status) " +
           "AND (:search IS NULL OR LOWER(d.medicineNameSnapshot) LIKE LOWER(CONCAT('%', :search, '%'))) " +
           "AND (:startDate IS NULL OR d.scheduledAt >= :startDate) " +
           "AND (:endDate IS NULL OR d.scheduledAt <= :endDate) " +
           "ORDER BY d.scheduledAt DESC")
    Page<DoseRecord> searchHistory(
            @Param("userId") Long userId,
            @Param("status") DoseStatus status,
            @Param("search") String search,
            @Param("startDate") Instant startDate,
            @Param("endDate") Instant endDate,
            Pageable pageable
    );

    Optional<DoseRecord> findFirstByUserIdAndScheduledAtAfterAndStatusOrderByScheduledAtAsc(
            Long userId,
            Instant after,
            DoseStatus status
    );

    boolean existsByMedicineIdAndScheduledAt(Long medicineId, Instant scheduledAt);

    @Modifying
    @Query("DELETE FROM DoseRecord d WHERE d.medicine.id = :medicineId AND d.scheduledAt >= :after AND d.status = 'PENDING'")
    void deleteFuturePendingDoses(@Param("medicineId") Long medicineId, @Param("after") Instant after);

    @Modifying
    @Query("UPDATE DoseRecord d SET d.status = 'MISSED' WHERE d.status = 'PENDING' AND d.scheduledAt < :cutoff")
    int markOverduePendingDosesAsMissed(@Param("cutoff") Instant cutoff);
}
