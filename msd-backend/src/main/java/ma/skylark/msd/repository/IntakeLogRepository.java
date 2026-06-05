package ma.skylark.msd.repository;

import ma.skylark.msd.domain.entity.IntakeLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public interface IntakeLogRepository extends JpaRepository<IntakeLog, UUID> {
    /**
     * Uses JOIN FETCH to load medication with logs efficiently for a specific date.
     */
    @Query("SELECT l FROM IntakeLog l JOIN FETCH l.medication m WHERE m.userId = :userId "
            + "AND l.intakeDate = :date")
    List<IntakeLog> findDailyLogs(@Param("userId") String userId, @Param("date") LocalDate date);

    /**
     * Uses JOIN FETCH to load medication with logs efficiently for a date range.
     */
    @Query("SELECT l FROM IntakeLog l JOIN FETCH l.medication m WHERE m.userId = :userId "
            + "AND l.intakeDate BETWEEN :startDate AND :endDate")
    List<IntakeLog> findLogsInRange(@Param("userId") String userId, 
                                   @Param("startDate") LocalDate startDate, 
                                   @Param("endDate") LocalDate endDate);
}