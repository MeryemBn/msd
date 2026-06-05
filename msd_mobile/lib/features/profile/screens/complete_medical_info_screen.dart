import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/msd_button.dart';
import '../providers/profile_provider.dart';

class CompleteMedicalInfoScreen extends ConsumerStatefulWidget {
  const CompleteMedicalInfoScreen({super.key});

  @override
  ConsumerState<CompleteMedicalInfoScreen> createState() => _CompleteMedicalInfoScreenState();
}

class _CompleteMedicalInfoScreenState extends ConsumerState<CompleteMedicalInfoScreen> {
  String? _bloodType;
  bool _isLoading = false;
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentBloodType();
    });
  }

  Future<void> _loadCurrentBloodType() async {
    await ref.read(profileProvider.notifier).loadProfile(silent: true);
    final records = ref.read(profileProvider).userProfile?.medicalRecords ?? [];
    final bloodRecord = records.where((r) => r.type == 'BLOOD_TYPE').firstOrNull;
    if (bloodRecord != null && mounted) {
      setState(() => _bloodType = bloodRecord.description);
    }
  }

  Future<void> _finishFlow() async {
    setState(() => _isLoading = true);
    try {
      // Pour le patient, on marque le profil comme complet à la fin du wizard
      await ref.read(profileProvider.notifier).markProfileAsComplete();
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onBloodTypeChanged(String? val) async {
    if (val == null || val == _bloodType) return;

    setState(() => _bloodType = val);
    final notifier = ref.read(profileProvider.notifier);
    final user = ref.read(profileProvider).userProfile;

    // Supprimer l'ancien record s'il existe
    final old = user?.medicalRecords.where((r) => r.type == 'BLOOD_TYPE').firstOrNull;
    if (old != null) {
      await notifier.deleteMedicalRecord(old.id!);
    }

    // Ajouter le nouveau immédiatement
    await notifier.addMedicalRecord('BLOOD_TYPE', val);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.medicalInfo,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ces informations nous aident à personnaliser vos soins.',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 40),

            _buildSectionTitle(l10n.bloodType),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _bloodType,
              dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              decoration: AppTheme.textFieldDecoration(hint: 'Sélectionnez votre groupe', isDark: isDark),
              items: _bloodTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: _onBloodTypeChanged,
            ),

            const SizedBox(height: 32),
            _buildDynamicSection('ALLERGY', l10n.allergies, Icons.warning_amber_rounded, Colors.orange),
            const SizedBox(height: 24),
            _buildDynamicSection('MEDICAL_HISTORY', l10n.history, Icons.history, Colors.blue),
            const SizedBox(height: 24),
            _buildDynamicSection('CHRONIC_DISEASE', l10n.chronicDiseases, Icons.favorite_border, Colors.red),

            const SizedBox(height: 48),
            MsdButton(
              text: l10n.save,
              isLoading: _isLoading,
              onPressed: _finishFlow,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildDynamicSection(String type, String label, IconData icon, Color color) {
    final records = ref.watch(profileProvider).userProfile?.medicalRecords.where((r) => r.type == type).toList() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(label),
            IconButton(
              onPressed: () => _showAddDialog(type, label),
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary, size: 28),
            ),
          ],
        ),
        if (records.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.1)),
            ),
            child: Text(
              'Aucun(e) $label ajouté(e)',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: records.map((r) => Chip(
              label: Text(r.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              avatar: Icon(icon, size: 16, color: color),
              backgroundColor: color.withOpacity(0.1),
              side: BorderSide(color: color.withOpacity(0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              onDeleted: () => ref.read(profileProvider.notifier).deleteMedicalRecord(r.id!),
              deleteIconColor: Colors.red.withOpacity(0.7),
            )).toList(),
          ),
      ],
    );
  }

  void _showAddDialog(String type, String label) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Ajouter $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Description...',
            filled: true,
            fillColor: Colors.grey.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(profileProvider.notifier).addMedicalRecord(type, controller.text);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
