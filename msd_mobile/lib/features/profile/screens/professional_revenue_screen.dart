import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/app_theme.dart';
import '../../../shared/widgets/section_header.dart';
import '../providers/revenue_provider.dart';
import '../models/revenue_stats.dart';

class ProfessionalRevenueScreen extends ConsumerWidget {
  const ProfessionalRevenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueAsync = ref.watch(revenueStatsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Tableau de Bord Financier", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: revenueAsync.when(
        data: (stats) => RefreshIndicator(
          onRefresh: () async => ref.refresh(revenueStatsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRevenueOverview(context, stats),
                const SizedBox(height: 24),
                _buildPricingActionCard(context),
                const SizedBox(height: 32),
                const SectionHeader(label: "Performance (6 derniers mois)"),
                const SizedBox(height: 20),
                _buildMonthlyChart(context, stats),
                const SizedBox(height: 32),
                const SectionHeader(label: "Historique des Gains"),
                const SizedBox(height: 12),
                _buildMonthlyList(context, stats),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erreur: $err")),
      ),
    );
  }

  Widget _buildRevenueOverview(BuildContext context, RevenueStats stats) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF2DBFAD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Chiffre d'affaires total",
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "${NumberFormat("#,###").format(stats.totalRevenue)} MAD",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem("Ce mois", "${stats.monthlyRevenue.toInt()} MAD"),
                Container(width: 1, height: 30, color: Colors.white24),
                _buildStatItem("Missions", "${stats.totalMissions}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPricingActionCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push('/pro-pricing'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.fieldBgDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.tune_rounded, color: AppTheme.primary),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Gestion des Tarifs",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "Ajustez vos prix et limites",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context, RevenueStats stats) {
    if (stats.revenueByMonth.isEmpty) return const SizedBox.shrink();
    
    final chartData = stats.revenueByMonth.length > 6 
        ? stats.revenueByMonth.sublist(stats.revenueByMonth.length - 6) 
        : stats.revenueByMonth;

    final maxAmount = chartData.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    
    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: chartData.map((m) {
          final heightFactor = maxAmount > 0 ? (m.amount / maxAmount) : 0.0;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (m.amount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        m.amount >= 1000 ? "${(m.amount/1000).toStringAsFixed(1)}k" : m.amount.toInt().toString(),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  ),
                Container(
                  width: 25,
                  height: (120 * heightFactor).clamp(4, 120).toDouble(),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary.withOpacity(0.8), AppTheme.primary.withOpacity(0.4)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(m.month, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMonthlyList(BuildContext context, RevenueStats stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reversedList = stats.revenueByMonth.reversed.toList();

    if (reversedList.isEmpty) {
      return const Center(child: Text("Aucun gain enregistré.", style: TextStyle(color: Colors.grey)));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reversedList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = reversedList[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.fieldBgDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.primary),
              ),
              const SizedBox(width: 16),
              Text(item.month, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const Spacer(),
              Text(
                "${NumberFormat("#,###").format(item.amount)} MAD",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
              ),
            ],
          ),
        );
      },
    );
  }
}
