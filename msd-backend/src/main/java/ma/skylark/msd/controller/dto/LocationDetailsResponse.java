package ma.skylark.msd.controller.dto;

import ma.skylark.msd.domain.entity.LocationDetails;

/**
 * DTO de réponse pour les détails de localisation d'une intervention SOS.
 */
public record LocationDetailsResponse(
        String address,
        String apartment,
        String floor,
        String entryCode,
        Double latitude,
        Double longitude
) {
    /**
     * Méthode utilitaire pour créer le DTO à partir de l'entité JPA.
     */
    public static LocationDetailsResponse fromEntity(LocationDetails entity) {
        if (entity == null) return null;
        return new LocationDetailsResponse(
                entity.getAddress(),
                entity.getApartment(),
                entity.getFloor(),
                entity.getEntryCode(),
                entity.getLatitude(),
                entity.getLongitude()
        );
    }
}