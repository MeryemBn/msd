import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final stats = state.stats;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 20,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: () => ref.read(adminProvider.notifier).loadDashboardData(),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeSection(isDark, l10n),
                          const SizedBox(height: 24),
                          _buildQuickStats(stats, isDark, l10n),
                          const SizedBox(height: 32),
                          
                          Text(l10n.adminManagementTools, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textDark)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildToolCard(context, l10n.adminProfessionals, l10n.adminManageNetwork, Icons.badge_rounded, Colors.blue, '/admin/professionals', isDark),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildToolCard(context, l10n.adminPatients, l10n.adminFullList, Icons.people_rounded, Colors.purple, '/admin/patients', isDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildToolCard(context, l10n.adminSosMonitor, l10n.adminLiveFlow, Icons.analytics_rounded, Colors.orange, '/admin/requests', isDark),
                          
                          const SizedBox(height: 32),
                          _buildDistributionSection(stats, isDark, l10n),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeSection(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.adminWelcome, 
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppTheme.textDark)),
        Text(l10n.adminPlatformStatus, 
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildQuickStats(stats, bool isDark, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildStatItem(l10n.adminTotalSos, stats.totalSosRequests.toString(), Icons.bolt_rounded, Colors.orange, cardWidth, isDark),
            _buildStatItem(l10n.adminMissions, stats.completedMissions.toString(), Icons.verified_rounded, Colors.green, cardWidth, isDark),
            _buildStatItem(l10n.adminValidatedPros, stats.totalProfessionals.toString(), Icons.medical_information_rounded, Colors.blue, cardWidth, isDark),
            _buildStatItem(l10n.adminPatients, stats.totalPatients.toString(), Icons.people_alt_rounded, Colors.purple, cardWidth, isDark),
          ],
        );
      }
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, double width, bool isDark) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (!isDark) BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, String title, String sub, IconData icon, Color color, String route, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionSection(stats, bool isDark, AppLocalizations l10n) {
    final Map<String, dynamic> requests = stats.requestsByService;
    final int total = (stats.totalSosRequests as num).toInt() > 0 ? (stats.totalSosRequests as num).toInt() : 1;

    int getCount(List<String> keys) {
      return keys.fold<int>(0, (sum, key) {
        final dynamic val = requests[key.toUpperCase()] ?? 0;
        final int intVal = (val is num) ? val.toInt() : 0;
        return sum + intVal;
      });
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminSosDistribution, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildServiceBar(l10n.adminDoctors, getCount(['DOCTOR', 'DOCTOR_HOME']), total, Colors.blue),
          _buildServiceBar(l10n.adminAmbulances, getCount(['AMBULANCE']), total, Colors.orange),
          _buildServiceBar(l10n.adminNurses, getCount(['NURSE']), total, Colors.green),
          _buildServiceBar(l10n.adminTeleconsult, getCount(['TELECONSULTATION', 'TELECONSULT']), total, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildServiceBar(String label, int count, int total, Color color) {
    final double percent = count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              Text("$count", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
