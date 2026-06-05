package ma.skylark.msd.controller.dto;

import ma.skylark.msd.domain.entity.ProfessionalDocument;
import java.time.Instant;

public record ProfessionalDocumentResponse(
    Long id,
    String documentType,
    String filePath,
    String fileName,
    String ocrResult,
    Instant uploadedAt
) {
    public static ProfessionalDocumentResponse fromEntity(ProfessionalDocument doc) {
        return new ProfessionalDocumentResponse(
            doc.getId(),
            doc.getDocumentType(),
            doc.getFilePath(),
            doc.getFileName(),
            doc.getOcrResult(),
            doc.getUploadedAt()
        );
    }
}
