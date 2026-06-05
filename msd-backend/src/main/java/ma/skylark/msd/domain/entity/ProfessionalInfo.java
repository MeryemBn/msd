package ma.skylark.msd.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import ma.skylark.msd.domain.model.ValidationStatus;

@Entity
@Table(name = "professional_info")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProfessionalInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private UserProfile user;

    @Column(name = "service_type", length = 100)
    private String serviceType;

    @Column(name = "specialty", length = 100)
    private String specialty;

    @Column(name = "ambulance_type", length = 100)
    private String ambulanceType;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(name = "status_validation")
    private ValidationStatus statusValidation = ValidationStatus.PENDING;

    @Column(name = "rejection_reason", length = 500)
    private String rejectionReason;

    @Builder.Default
    @Column(name = "is_available")
    private Boolean isAvailable = false;

    @Builder.Default
    @Column(name = "average_rating")
    private Double averageRating = 0.0;

    @Builder.Default
    @Column(name = "total_reviews")
    private Integer totalReviews = 0;

    @Builder.Default
    @Column(name = "completed_missions_count")
    private Integer completedMissionsCount = 0;

    public ProfessionalInfo(UserProfile user, String serviceType, String specialty) {
        this.user = user;
        this.serviceType = serviceType;
        this.specialty = specialty;
    }

    public void updateRating(int newRating) {
        double currentTotal = (averageRating != null ? averageRating : 0.0) * (totalReviews != null ? totalReviews : 0);
        if (totalReviews == null) totalReviews = 0;
        totalReviews++;
        averageRating = (currentTotal + newRating) / totalReviews;
    }

    public void incrementCompletedMissions() {
        if (this.completedMissionsCount == null) {
            this.completedMissionsCount = 0;
        }
        this.completedMissionsCount++;
    }
}
