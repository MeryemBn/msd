package ma.skylark.msd.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;

@Entity
@Table(name = "professional_documents")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProfessionalDocument {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "professional_info_id", nullable = false)
    private ProfessionalInfo professionalInfo;

    @Column(name = "document_type", nullable = false)
    private String documentType; // e.g., CNI_FRONT, DIPLOMA, etc.

    @Column(name = "file_path", nullable = false)
    private String filePath;

    @Column(name = "file_name")
    private String fileName;

    @Column(name = "ocr_result", columnDefinition = "TEXT")
    private String ocrResult; // Store extracted text or JSON summary

    @CreationTimestamp
    @Column(name = "uploaded_at", nullable = false, updatable = false)
    private Instant uploadedAt;
}
