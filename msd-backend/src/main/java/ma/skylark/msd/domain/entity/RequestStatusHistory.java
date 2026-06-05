package ma.skylark.msd.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Audit trail entry for every status change on an SOS request.
 * changed_by references the user_profiles.id of whoever triggered the change.
 */
@Entity
@Table(name = "request_status_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RequestStatusHistory {

    @Id
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "request_id", nullable = false)
    private SosRequest sosRequest;

    @Column(name = "changed_by", nullable = false)
    private Long changedBy;

    @Column(name = "status", nullable = false, length = 30)
    private String status;

    @Column(name = "reason", columnDefinition = "TEXT")
    private String reason;

    @CreationTimestamp
    @Column(name = "changed_at", nullable = false, updatable = false)
    private LocalDateTime changedAt;
}
