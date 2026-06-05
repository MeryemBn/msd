package ma.skylark.msd.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "pricing_history")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PricingHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "professional_id", nullable = false)
    private Long professionalId;

    @Column(name = "service_type", nullable = false, length = 50)
    private String serviceType;

    @Column(name = "specialty", length = 100)
    private String specialty;

    @Column(name = "ambulance_type", length = 50)
    private String ambulanceType;

    @Column(name = "intervention_mode", length = 50)
    private String interventionMode;

    @Column(name = "old_price", precision = 12, scale = 2)
    private BigDecimal oldPrice;

    @Column(name = "new_price", nullable = false, precision = 12, scale = 2)
    private BigDecimal newPrice;

    @CreationTimestamp
    @Column(name = "changed_at", updatable = false)
    private LocalDateTime changedAt;
}
