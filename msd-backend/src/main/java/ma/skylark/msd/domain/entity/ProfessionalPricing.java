package ma.skylark.msd.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "professional_pricing")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProfessionalPricing {

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

    @Column(name = "price", nullable = false, precision = 12, scale = 2)
    private BigDecimal price;

    @Column(name = "extra_km_price", precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal extraKmPrice = BigDecimal.ZERO;

    @Column(name = "km_radius_included")
    @Builder.Default
    private Integer kmRadiusIncluded = 0;

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
