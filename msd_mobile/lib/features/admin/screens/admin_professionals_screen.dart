import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/admin_provider.dart';

class AdminProfessionalsScreen extends ConsumerStatefulWidget {
  final String initialFilter;
  const AdminProfessionalsScreen({super.key, this.initialFilter = 'ALL'});

  @override
  ConsumerState<AdminProfessionalsScreen> createState() => _AdminProfessionalsScreenState();
}

class _AdminProfessionalsScreenState extends ConsumerState<AdminProfessionalsScreen> {
  String _searchQuery = '';
  late String _statusFilter;

  @override
  void initState() {
    super.initState();
    _statusFilter = widget.initialFilter;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadAllProfessionals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final filteredPros = state.allProfessionals.where((pro) {
      final nameMatch = pro.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
      final statusStr = pro.status.toString().split('.').last.toUpperCase();
      final statusMatch = _statusFilter == 'ALL' || statusStr == _statusFilter;
      return nameMatch && statusMatch;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.proDirectory),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: l10n.searchProHint,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark ? AppTheme.fieldBgDark : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(l10n.filterAll, "ALL"),
                      _buildFilterChip(l10n.filterValidated, "VALIDATED"),
                      _buildFilterChip(l10n.filterPending, "PENDING"),
                      _buildFilterChip(l10n.filterRejected, "REJECTED"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: state.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : filteredPros.isEmpty
              ? _buildEmptyState(l10n)
              : RefreshIndicator(
                  onRefresh: () => ref.read(adminProvider.notifier).loadAllProfessionals(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPros.length,
                    itemBuilder: (context, index) {
                      final pro = filteredPros[index];
                      return _buildProCard(context, pro, isDark, l10n);
                    },
                  ),
                ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey)),
        selected: isSelected,
        selectedColor: AppTheme.primary,
        onSelected: (selected) {
          if (selected) setState(() => _statusFilter = value);
        },
      ),
    );
  }

  Widget _buildProCard(BuildContext context, pro, bool isDark, AppLocalizations l10n) {
    final statusStr = pro.status.toString().split('.').last.toUpperCase();
    String displayStatus;
    Color statusColor;
    
    switch (statusStr) {
      case 'VALIDATED': 
        statusColor = Colors.green; 
        displayStatus = l10n.validated;
        break;
      case 'REJECTED': 
        statusColor = Colors.red; 
        displayStatus = l10n.rejected;
        break;
      default: 
        statusColor = Colors.orange;
        displayStatus = l10n.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: Text(pro.firstName[0], style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(pro.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(pro.serviceType ?? "Pro", style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text(displayStatus.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/admin/professional-detail', extra: pro),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(child: Text(l10n.noResultFound));
  }
}
