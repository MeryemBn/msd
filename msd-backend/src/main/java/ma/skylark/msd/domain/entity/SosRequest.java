package ma.skylark.msd.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "sos_requests")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SosRequest {

    @Id
    private UUID id;

    @Column(name = "patient_id", nullable = false)
    private Long patientId;

    @Column(name = "professional_id")
    private Long professionalId;

    @Column(name = "service_type", nullable = false, length = 50)
    private String serviceType;

    @Column(name = "ambulance_type", length = 50)
    private String ambulanceType;

    @Column(name = "specialty", length = 100)
    private String specialty;

    @Column(name = "intervention_mode", nullable = false, length = 50)
    private String interventionMode;

    @Column(name = "appointment_datetime")
    private LocalDateTime appointmentDatetime;

    @Column(name = "payment_method", nullable = false, length = 50)
    private String paymentMethod;

    @Column(name = "price", precision = 12, scale = 2)
    private BigDecimal price;

    @Column(name = "status", nullable = false, length = 30)
    private String status;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @OneToOne(mappedBy = "sosRequest", cascade = CascadeType.ALL, fetch = FetchType.EAGER, optional = true)
    private LocationDetails location;

    @OneToMany(mappedBy = "sosRequest", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    @Builder.Default
    private List<RequestStatusHistory> statusHistory = new ArrayList<>();
}