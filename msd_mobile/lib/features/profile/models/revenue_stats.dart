class RevenueStats {
  final double totalRevenue;
  final double monthlyRevenue;
  final int totalMissions;
  final List<MonthlyRevenue> revenueByMonth;

  RevenueStats({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.totalMissions,
    required this.revenueByMonth,
  });

  factory RevenueStats.fromJson(Map<String, dynamic> json) {
    return RevenueStats(
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] as num).toDouble(),
      totalMissions: json['totalMissions'] as int,
      revenueByMonth: (json['revenueByMonth'] as List)
          .map((e) => MonthlyRevenue.fromJson(e))
          .toList(),
    );
  }
}

class MonthlyRevenue {
  final String month;
  final double amount;

  MonthlyRevenue({required this.month, required this.amount});

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenue(
      month: json['month'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
