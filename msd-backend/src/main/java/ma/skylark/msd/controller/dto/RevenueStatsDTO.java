package ma.skylark.msd.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RevenueStatsDTO {
    private BigDecimal totalRevenue;
    private BigDecimal monthlyRevenue;
    private Integer totalMissions;
    private List<MonthlyRevenue> revenueByMonth;

    @Data
    @AllArgsConstructor
    public static class MonthlyRevenue {
        private String month; // e.g., "JAN", "FEB"
        private BigDecimal amount;
    }
}
