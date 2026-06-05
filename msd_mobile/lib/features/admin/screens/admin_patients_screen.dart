import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_theme.dart';
import '../providers/admin_provider.dart';
import '../../profile/models/medical_record.dart';

class AdminPatientsScreen extends ConsumerStatefulWidget {
  const AdminPatientsScreen({super.key});

  @override
  ConsumerState<AdminPatientsScreen> createState() => _AdminPatientsScreenState();
}

class _AdminPatientsScreenState extends ConsumerState<AdminPatientsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadAllPatients();
    });
  }

  void _showPatientDetails(patient) {
    // Debug pour voir ce que l'on reçoit réellement
    print("Patient Medical Records Count: ${patient.medicalRecords?.length}");
    if (patient.medicalRecords != null) {
      for (var r in patient.medicalRecords) {
        print("Record: Type=${r.type}, Desc=${r.description}");
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: Text(patient.firstName?[0] ?? 'P', style: const TextStyle(fontSize: 24, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${patient.firstName ?? ''} ${patient.lastName ?? ''}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(patient.email ?? "Pas d'email", style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text("Informations Personnelles", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.phone_rounded, "Téléphone", patient.phoneNumber ?? "Non renseigné"),
                    _buildDetailRow(Icons.location_on_rounded, "Adresse", patient.address ?? "Non renseignée"),
                    _buildDetailRow(Icons.location_city_rounded, "Ville", patient.city ?? "Non renseignée"),
                    
                    const SizedBox(height: 24),
                    const Text("Informations Médicales", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildMedicalSection(patient.medicalRecords ?? []),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalSection(List<MedicalRecord> records) {
    // On normalize les types en majuscules pour éviter les problèmes de casse
    final bloodType = records.where((r) => r.type.toUpperCase() == 'BLOOD_TYPE').map((r) => r.description).firstOrNull;
    final allergies = records.where((r) => r.type.toUpperCase() == 'ALLERGY').map((r) => r.description).where((d) => d.trim().isNotEmpty).toList();
    final history = records.where((r) => r.type.toUpperCase() == 'MEDICAL_HISTORY').map((r) => r.description).where((d) => d.trim().isNotEmpty).toList();
    final chronic = records.where((r) => r.type.toUpperCase() == 'CHRONIC_DISEASE').map((r) => r.description).where((d) => d.trim().isNotEmpty).toList();

    if (bloodType == null && allergies.isEmpty && history.isEmpty && chronic.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Aucune information médicale renseignée pour ce patient.",
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (bloodType != null)
          _buildDetailRow(Icons.water_drop_outlined, "Groupe Sanguin", bloodType, color: Colors.redAccent),
        
        if (allergies.isNotEmpty)
          _buildChipsSection("Allergies", allergies, Icons.warning_amber_rounded, Colors.orange),
          
        if (history.isNotEmpty)
          _buildChipsSection("Historique", history, Icons.history, Colors.blue),
          
        if (chronic.isNotEmpty)
          _buildChipsSection("Maladies Chroniques", chronic, Icons.favorite_border_rounded, Colors.red),
      ],
    );
  }

  Widget _buildChipsSection(String label, List<String> items, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: items.map((item) => Chip(
                    label: Text(item, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                    backgroundColor: color.withOpacity(0.08),
                    side: BorderSide(color: color.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? AppTheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color ?? AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredPatients = state.allPatients.where((p) {
      final fullName = "${p.firstName ?? ''} ${p.lastName ?? ''}".toLowerCase();
      return fullName.contains(_searchQuery.toLowerCase()) || 
             (p.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Liste des Patients"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: "Rechercher un patient...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? AppTheme.fieldBgDark : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: state.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : filteredPatients.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => ref.read(adminProvider.notifier).loadAllPatients(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      return _buildPatientCard(patient, isDark);
                    },
                  ),
                ),
    );
  }

  Widget _buildPatientCard(patient, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.1),
          child: Text(patient.firstName?[0] ?? 'P', style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
        ),
        title: Text("${patient.firstName ?? ''} ${patient.lastName ?? ''}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(patient.email ?? "Pas d'email", style: const TextStyle(fontSize: 12)),
            if (patient.phoneNumber != null)
              Text(patient.phoneNumber!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showPatientDetails(patient),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("Aucun patient trouvé"),
    );
  }
}
