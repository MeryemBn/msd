package ma.skylark.msd.controller;

import lombok.RequiredArgsConstructor;
import ma.skylark.msd.domain.entity.ProfessionalPricing;
import ma.skylark.msd.domain.entity.UserProfile;
import ma.skylark.msd.repository.UserProfileRepository;
import ma.skylark.msd.service.PricingService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Contrôleur pour la tarification professionnelle.
 */
@RestController
@RequestMapping("/api/pricing")
@RequiredArgsConstructor
public class PricingController {

    private final PricingService pricingService;
    private final UserProfileRepository userProfileRepository;

    @GetMapping("/professional/my-prices")
    public ResponseEntity<List<ProfessionalPricing>> getMyPrices(@AuthenticationPrincipal Jwt jwt) {
        UserProfile profile = userProfileRepository.findByKeycloakId(jwt.getSubject())
                .orElseThrow(() -> new RuntimeException("User not found"));
        return ResponseEntity.ok(pricingService.getProfessionalPricings(profile.getId()));
    }

    @PostMapping("/professional/set-price")
    public ResponseEntity<ProfessionalPricing> setPrice(
            @AuthenticationPrincipal Jwt jwt,
            @RequestBody Map<String, Object> request) {
        UserProfile profile = userProfileRepository.findByKeycloakId(jwt.getSubject())
                .orElseThrow(() -> new RuntimeException("User not found"));

        String serviceType = (String) request.get("serviceType");
        String specialty = (String) request.get("specialty");
        String ambulanceType = (String) request.get("ambulanceType");
        String interventionMode = (String) request.get("interventionMode");
        BigDecimal price = new BigDecimal(request.get("price").toString());
        
        BigDecimal extraKmPrice = request.get("extraKmPrice") != null ? 
                new BigDecimal(request.get("extraKmPrice").toString()) : BigDecimal.ZERO;
        Integer kmRadius = request.get("kmRadiusIncluded") != null ? 
                Integer.parseInt(request.get("kmRadiusIncluded").toString()) : 0;

        return ResponseEntity.ok(pricingService.setProfessionalPrice(
                profile.getId(), serviceType, specialty, ambulanceType, interventionMode, 
                price, extraKmPrice, kmRadius));
    }

    @GetMapping("/calculate")
    public ResponseEntity<Map<String, BigDecimal>> calculatePrice(
            @RequestParam Long professionalId,
            @RequestParam String serviceType,
            @RequestParam(required = false) String specialty,
            @RequestParam(required = false) String ambulanceType,
            @RequestParam String interventionMode,
            @RequestParam(required = false) Double distanceKm) {
        
        BigDecimal price = pricingService.calculateFinalPrice(
                professionalId, serviceType, specialty, ambulanceType, interventionMode, distanceKm);
        
        return ResponseEntity.ok(Map.of("price", price));
    }

    @GetMapping("/average-price")
    public ResponseEntity<Map<String, BigDecimal>> getAveragePrice(
            @RequestParam String serviceType,
            @RequestParam(required = false) String specialty,
            @RequestParam(required = false) String ambulanceType,
            @RequestParam String interventionMode) {
        
        BigDecimal avgPrice = pricingService.getAvgPriceForService(
                serviceType, specialty, ambulanceType, interventionMode);
        
        return ResponseEntity.ok(Map.of("averagePrice", avgPrice));
    }
}
