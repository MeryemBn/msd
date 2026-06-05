import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/widgets/chatbot_sheet.dart';
import '../models/request_details.dart';
import '../models/sos_request.dart';
import '../models/sos_enums.dart';
import '../providers/sos_provider.dart';
import '../widgets/sos_request_detail_sheet.dart';

enum SosFilter { all, ongoing, completed, cancelled }

class SosRequestsHistoryScreen extends ConsumerStatefulWidget {
  const SosRequestsHistoryScreen({super.key});

  @override
  ConsumerState<SosRequestsHistoryScreen> createState() => _SosRequestsHistoryScreenState();
}

class _SosRequestsHistoryScreenState extends ConsumerState<SosRequestsHistoryScreen> {
  SosFilter _selectedFilter = SosFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(sosProvider.notifier).loadMyRequests());
  }

  void _showChatbot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatbotSheet(),
    );
  }

  List<SosRequest> _filterRequests(List<SosRequest> requests) {
    switch (_selectedFilter) {
      case SosFilter.all:
        return requests;
      case SosFilter.ongoing:
        return requests.where((r) => 
          r.status == RequestStatus.pending || 
          r.status == RequestStatus.awaiting_payment || 
          r.status == RequestStatus.confirmed || 
          r.status == RequestStatus.on_the_way ||
          r.status == RequestStatus.in_progress).toList();
      case SosFilter.completed:
        return requests.where((r) => r.status == RequestStatus.completed).toList();
      case SosFilter.cancelled:
        return requests.where((r) => 
          r.status == RequestStatus.cancelled || 
          r.status == RequestStatus.rejected).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sosProvider);
    final allRequests = state.myRequests;
    final List<SosRequest> filteredRequests = _filterRequests(allRequests);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myRequestsTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          _buildFilterBar(l10n),
          Expanded(
            child: state.isLoading && allRequests.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : RefreshIndicator(
                  onRefresh: () => ref.read(sosProvider.notifier).loadMyRequests(),
                  color: AppTheme.primary,
                  child: filteredRequests.isEmpty 
                    ? _buildEmptyState(context, l10n)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) => _RequestCard(request: filteredRequests[index]),
                      ),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChatbot(context),
        backgroundColor: AppTheme.primary,
        elevation: 4,
        child: const Icon(
          Icons.smart_toy_rounded,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilterBar(AppLocalizations l10n) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: l10n.filterAll,
            isSelected: _selectedFilter == SosFilter.all,
            onTap: () => setState(() => _selectedFilter = SosFilter.all),
          ),
          _FilterChip(
            label: l10n.filterOngoing,
            isSelected: _selectedFilter == SosFilter.ongoing,
            onTap: () => setState(() => _selectedFilter = SosFilter.ongoing),
          ),
          _FilterChip(
            label: l10n.filterCompleted,
            isSelected: _selectedFilter == SosFilter.completed,
            onTap: () => setState(() => _selectedFilter = SosFilter.completed),
          ),
          _FilterChip(
            label: l10n.filterCancelled,
            isSelected: _selectedFilter == SosFilter.cancelled,
            onTap: () => setState(() => _selectedFilter = SosFilter.cancelled),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_late_outlined, 
                size: 64, 
                color: isDark ? Colors.white12 : Colors.grey.shade300
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noRequests,
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _getEmptyStateMessage(l10n),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyStateMessage(AppLocalizations l10n) {
    switch (_selectedFilter) {
      case SosFilter.all: return l10n.noRequestsAll;
      case SosFilter.ongoing: return l10n.noRequestsOngoing;
      case SosFilter.completed: return l10n.noRequestsCompleted;
      case SosFilter.cancelled: return l10n.noRequestsCancelled;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.1) 
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? AppTheme.primary 
                  : (isDark ? Colors.white60 : Colors.grey.shade700),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final SosRequest request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateToShow = request.createdAt ?? DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;
    final formattedDate = DateFormat('dd MMM yyyy • HH:mm', locale).format(dateToShow);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final locationLabel = request.details.interventionDetails.location?.address ?? _getSubtitle(l10n);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade100),
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => SosRequestDetailSheet(request: request),
        ),
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50, 
            borderRadius: BorderRadius.circular(12)
          ),
          child: Icon(_getIcon(), color: isDark ? Colors.white70 : Colors.black87),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _getTitle(l10n),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ),
            _StatusBadge(status: request.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              locationLabel, 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.grey.shade600)
            ),
            const SizedBox(height: 4),
            Text(
              formattedDate, 
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white30 : Colors.grey.shade400)
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    final details = request.details;
    if (details is DoctorDetails) return Icons.medical_services_outlined;
    if (details is NurseDetails) return Icons.health_and_safety_outlined;
    if (details is TeleconsultDetails) return Icons.videocam_outlined;
    if (details is AmbulanceDetails) return Icons.medical_services;
    return Icons.medical_services_outlined;
  }

  String _getTitle(AppLocalizations l10n) {
    final details = request.details;
    if (details is DoctorDetails) return l10n.doctor;
    if (details is NurseDetails) return l10n.nurse;
    if (details is TeleconsultDetails) return l10n.teleconsultation;
    if (details is AmbulanceDetails) return l10n.ambulance;
    return 'SOS';
  }

  String _getSubtitle(AppLocalizations l10n) {
    final details = request.details;
    if (details is DoctorDetails) return details.specialty.getLabel(l10n);
    if (details is NurseDetails) return l10n.homeCare;
    if (details is TeleconsultDetails) return l10n.videoConsultation(details.specialty.getLabel(l10n));
    if (details is AmbulanceDetails) return details.ambulanceType.getLabel(l10n);
    return l10n.healthServices;
  }
}

class _StatusBadge extends StatelessWidget {
  final RequestStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    switch (status) {
      case RequestStatus.on_the_way: color = const Color(0xFF2DBFAD); break;
      case RequestStatus.cancelled: color = Colors.red.shade400; break;
      case RequestStatus.completed: color = Colors.grey; break;
      case RequestStatus.pending: color = Colors.orange.shade400; break;
      case RequestStatus.awaiting_payment: color = Colors.amber.shade700; break;
      case RequestStatus.confirmed: color = Colors.blue; break;
      case RequestStatus.in_progress: color = Colors.teal; break;
      case RequestStatus.rejected: color = Colors.red; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status.getLabel(l10n), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
