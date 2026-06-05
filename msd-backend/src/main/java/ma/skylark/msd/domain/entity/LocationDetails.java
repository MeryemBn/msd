package ma.skylark.msd.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

/**
 * Location details for an SOS intervention, stored in a separate table.
 */
@Entity
@Table(name = "location_details")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LocationDetails {

    @Id
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "request_id", nullable = false)
    private SosRequest sosRequest;

    @Column(name = "address", nullable = false, length = 500)
    private String address;

    @Column(name = "apartment", length = 100)
    private String apartment;

    @Column(name = "floor", length = 50)
    private String floor;

    @Column(name = "entry_code", length = 50)
    private String entryCode;

    @Column(name = "latitude", nullable = false)
    private Double latitude;

    @Column(name = "longitude", nullable = false)
    private Double longitude;
}
