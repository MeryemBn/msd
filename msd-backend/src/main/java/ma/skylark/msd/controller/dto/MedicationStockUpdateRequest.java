package ma.skylark.msd.controller.dto;

/**
 * DTO for updating the stock of a medication. Contains the new current stock value.
 */
public record MedicationStockUpdateRequest(int currentStock) {}