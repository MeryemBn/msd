package ma.skylark.msd.service;

import lombok.RequiredArgsConstructor;
import ma.skylark.msd.domain.entity.PricingHistory;
import ma.skylark.msd.domain.entity.ProfessionalPricing;
import ma.skylark.msd.repository.PricingHistoryRepository;
import ma.skylark.msd.repository.ProfessionalPricingRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PricingService {

    private final ProfessionalPricingRepository professionalPricingRepository;
    private final PricingHistoryRepository pricingHistoryRepository;

    @Transactional(readOnly = true)
    public List<ProfessionalPricing> getProfessionalPricings(Long professionalId) {
        return professionalPricingRepository.findByProfessionalId(professionalId);
    }

    @Transactional
    public ProfessionalPricing setProfessionalPrice(Long professionalId, String serviceType, String specialty, String ambulanceType, String interventionMode, BigDecimal price, BigDecimal extraKmPrice, Integer kmRadius) {
        String normService = serviceType.toUpperCase(Locale.ROOT);
        String normSpec = specialty != null ? specialty.toUpperCase(Locale.ROOT) : null;
        String normAmb = ambulanceType != null ? ambulanceType.toUpperCase(Locale.ROOT) : null;
        String normMode = interventionMode.toUpperCase(Locale.ROOT);

        Optional<ProfessionalPricing> existingPricing = professionalPricingRepository.findPricingCustom(
                professionalId, normService, normSpec, normAmb, normMode);

        BigDecimal oldPrice = null;
        ProfessionalPricing pricing;

        if (existingPricing.isPresent()) {
            pricing = existingPricing.get();
            oldPrice = pricing.getPrice();
            pricing.setPrice(price);
            pricing.setExtraKmPrice(extraKmPrice != null ? extraKmPrice : BigDecimal.ZERO);
            pricing.setKmRadiusIncluded(kmRadius != null ? kmRadius : 0);
        } else {
            pricing = ProfessionalPricing.builder()
                    .professionalId(professionalId)
                    .serviceType(normService)
                    .specialty(normSpec)
                    .ambulanceType(normAmb)
                    .interventionMode(normMode)
                    .price(price)
                    .extraKmPrice(extraKmPrice != null ? extraKmPrice : BigDecimal.ZERO)
                    .kmRadiusIncluded(kmRadius != null ? kmRadius : 0)
                    .isActive(true)
                    .build();
        }

        ProfessionalPricing saved = professionalPricingRepository.save(pricing);

        PricingHistory history = PricingHistory.builder()
                .professionalId(professionalId)
                .serviceType(normService)
                .specialty(normSpec)
                .ambulanceType(normAmb)
                .interventionMode(normMode)
                .oldPrice(oldPrice)
                .newPrice(price)
                .build();
        pricingHistoryRepository.save(history);

        return saved;
    }

    @Transactional(readOnly = true)
    public BigDecimal calculateFinalPrice(Long professionalId, String serviceType, String specialty, String ambulanceType, String interventionMode, Double distanceKm) {
        Optional<ProfessionalPricing> pricingOpt = professionalPricingRepository.findPricingCustom(
                        professionalId, serviceType, specialty, ambulanceType, interventionMode);
        
        if (pricingOpt.isEmpty()) return BigDecimal.ZERO;
        
        ProfessionalPricing pricing = pricingOpt.get();
        BigDecimal finalPrice = pricing.getPrice();
        
        // Calcul des frais KM uniquement pour SOS_URGENCY ou AMBULANCE
        boolean isUrgent = "SOS_URGENCY".equalsIgnoreCase(interventionMode);
        boolean isAmbulance = "AMBULANCE".equalsIgnoreCase(serviceType);

        if ((isUrgent || isAmbulance) && distanceKm != null && pricing.getExtraKmPrice() != null && pricing.getExtraKmPrice().compareTo(BigDecimal.ZERO) > 0) {
            int radius = pricing.getKmRadiusIncluded() != null ? pricing.getKmRadiusIncluded() : 0;
            double billableKm = Math.max(0, distanceKm - radius);

            if (billableKm > 0) {
                BigDecimal extraFees = pricing.getExtraKmPrice().multiply(BigDecimal.valueOf(billableKm));
                finalPrice = finalPrice.add(extraFees);
            }
        }
        
        return finalPrice;
    }

    @Transactional(readOnly = true)
    public BigDecimal getAvgPriceForService(String serviceType, String specialty, String ambulanceType, String interventionMode) {
        BigDecimal avgPrice = professionalPricingRepository.getAvgPriceForService(serviceType, specialty, ambulanceType, interventionMode);
        return avgPrice != null ? avgPrice : BigDecimal.ZERO;
    }
}
