import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/admin_provider.dart';
import '../../sos/shared/models/sos_enums.dart';
import '../../sos/shared/models/sos_request.dart';
import '../../sos/shared/models/request_details.dart';

class AdminRequestsScreen extends ConsumerStatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  ConsumerState<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends ConsumerState<AdminRequestsScreen> {
  String _statusFilter = 'ALL';
  String _dateFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadAllRequests();
    });
  }

  bool _applyDateFilter(DateTime? createdAt) {
    if (createdAt == null) return _dateFilter == 'ALL';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

    switch (_dateFilter) {
      case 'TODAY': return createdDate.isAtSameMomentAs(today);
      case 'WEEK': return createdAt.isAfter(now.subtract(const Duration(days: 7)));
      case 'MONTH': return createdAt.year == now.year && createdAt.month == now.month;
      default: return true;
    }
  }

  void _showRequestDetails(SosRequest req, AppLocalizations l10n) {
    final statusStr = req.status.getLabel(l10n).toUpperCase();
    final details = req.details;
    
    String serviceLabel = "SOS";
    String motiveLabel = l10n.description;
    String motiveValue = "N/A";

    if (details is DoctorDetails) {
      serviceLabel = l10n.doctor;
      motiveLabel = l10n.specialty;
      motiveValue = details.specialty.getLabel(l10n);
    } else if (details is AmbulanceDetails) {
      serviceLabel = l10n.ambulance;
      motiveLabel = l10n.ambulanceType;
      motiveValue = details.ambulanceType.getLabel(l10n);
    } else if (details is NurseDetails) {
      serviceLabel = l10n.nurse;
      motiveLabel = l10n.description;
      motiveValue = l10n.homeCare;
    } else if (details is TeleconsultDetails) {
      serviceLabel = l10n.teleconsultation;
      motiveLabel = l10n.specialty;
      motiveValue = details.specialty.getLabel(l10n);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.adminRequestDetails, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(statusStr, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(l10n.patient),
              _buildDetailItem(Icons.person_outline, l10n.fullName, req.patientFullName),
              _buildDetailItem(Icons.phone_outlined, l10n.phone, req.patientPhoneNumber ?? "N/A"),
              const Divider(height: 32),
              _buildSectionTitle(l10n.adminServiceIntervention),
              _buildDetailItem(Icons.medical_services_outlined, l10n.serviceType, serviceLabel),
              _buildDetailItem(Icons.info_outline, motiveLabel, motiveValue),
              _buildDetailItem(Icons.calendar_today_outlined, l10n.adminCreationDate, req.createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(req.createdAt!) : "N/A"),
              if (req.details.interventionDetails.appointmentDateTime != null)
                _buildDetailItem(Icons.alarm_on_outlined, l10n.adminAppointmentDate, DateFormat('dd/MM/yyyy HH:mm').format(req.details.interventionDetails.appointmentDateTime!)),
              const Divider(height: 32),
              _buildSectionTitle(l10n.adminAssignedPro),
              if (req.professionalFullName.isNotEmpty) ...[
                _buildDetailItem(Icons.badge_outlined, l10n.fullName, req.professionalFullName),
                _buildDetailItem(Icons.phone_android_outlined, l10n.phone, req.professionalPhoneNumber ?? "N/A"),
              ] else
                Text(l10n.adminNotYetAssigned, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
              const Divider(height: 32),
              _buildSectionTitle(l10n.payment),
              _buildDetailItem(Icons.payments_outlined, l10n.paymentMethod, req.paymentMethod.getLabel(l10n)),
              _buildDetailItem(Icons.money_rounded, l10n.totalRevenue, "${req.price} MAD"),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final filteredRequests = state.allRequests.where((req) {
      bool matchStatus = true;
      if (_statusFilter != 'ALL') {
        matchStatus = (req.status.name.toUpperCase() == _statusFilter);
      }
      return matchStatus && _applyDateFilter(req.createdAt);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.adminRequestsMonitor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    _buildFilterChip(l10n.filterAll, "ALL", true),
                    _buildFilterChip(l10n.filterPending, "PENDING", true),
                    _buildFilterChip(l10n.filterConfirmed, "CONFIRMED", true),
                    _buildFilterChip(l10n.filterInProgress, "IN_PROGRESS", true),
                    _buildFilterChip(l10n.filterCompleted, "COMPLETED", true),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    _buildFilterChip(l10n.adminAllDates, "ALL", false),
                    _buildFilterChip(l10n.today, "TODAY", false),
                    _buildFilterChip(l10n.adminThisWeek, "WEEK", false),
                    _buildFilterChip(l10n.adminThisMonth, "MONTH", false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: state.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : filteredRequests.isEmpty
              ? Center(child: Text(l10n.noRequests))
              : RefreshIndicator(
                  onRefresh: () => ref.read(adminProvider.notifier).loadAllRequests(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(filteredRequests[index], isDark, l10n);
                    },
                  ),
                ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isStatus) {
    final isSelected = isStatus ? _statusFilter == value : _dateFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey)),
        selected: isSelected,
        selectedColor: isStatus ? AppTheme.primary : Colors.blueGrey,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              if (isStatus) _statusFilter = value;
              else _dateFilter = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildRequestCard(SosRequest req, bool isDark, AppLocalizations l10n) {
    Color statusColor;
    final statusStr = req.status.getLabel(l10n).toUpperCase();
    final details = req.details;
    
    switch (req.status) {
      case RequestStatus.pending: statusColor = Colors.orange; break;
      case RequestStatus.confirmed: statusColor = Colors.blue; break;
      case RequestStatus.on_the_way:
      case RequestStatus.in_progress: statusColor = Colors.purple; break;
      case RequestStatus.completed: statusColor = Colors.green; break;
      default: statusColor = Colors.grey;
    }

    String serviceLabel = "SOS";
    String motiveValue = "N/A";

    if (details is DoctorDetails) {
      serviceLabel = l10n.doctor;
      motiveValue = details.specialty.getLabel(l10n);
    } else if (details is AmbulanceDetails) {
      serviceLabel = l10n.ambulance;
      motiveValue = details.ambulanceType.getLabel(l10n);
    } else if (details is NurseDetails) {
      serviceLabel = l10n.nurse;
      motiveValue = l10n.homeCare;
    } else if (details is TeleconsultDetails) {
      serviceLabel = l10n.teleconsultation;
      motiveValue = details.specialty.getLabel(l10n);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showRequestDetails(req, l10n),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(statusStr, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  Text(serviceLabel.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(req.patientFullName, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.medical_services_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(motiveValue, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${req.price} MAD", style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  if (req.createdAt != null)
                    Text(DateFormat('dd/MM HH:mm').format(req.createdAt!), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
