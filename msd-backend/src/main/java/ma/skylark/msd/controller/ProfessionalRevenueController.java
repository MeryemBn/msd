package ma.skylark.msd.controller;

import lombok.RequiredArgsConstructor;
import ma.skylark.msd.controller.dto.RevenueStatsDTO;
import ma.skylark.msd.service.ProfessionalService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/professional/revenue")
@RequiredArgsConstructor
public class ProfessionalRevenueController {

    private final ProfessionalService professionalService;

    @GetMapping("/stats")
    public ResponseEntity<RevenueStatsDTO> getRevenueStats(@AuthenticationPrincipal Jwt jwt) {
        return ResponseEntity.ok(professionalService.getRevenueStats(jwt.getSubject()));
    }
}
