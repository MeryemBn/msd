import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/profile_provider.dart';
import '../../sos/shared/models/sos_enums.dart';
import '../../auth/models/auth_user.dart';
import '../../../shared/widgets/msd_button.dart';

class ProfessionalSetupScreen extends ConsumerStatefulWidget {
  const ProfessionalSetupScreen({super.key});

  @override
  ConsumerState<ProfessionalSetupScreen> createState() => _ProfessionalSetupScreenState();
}

class _ProfessionalSetupScreenState extends ConsumerState<ProfessionalSetupScreen> {
  String? _selectedService;
  Specialty? _selectedSpecialty;
  final List<AmbulanceType> _selectedAmbulanceTypes = [];

  final List<Map<String, dynamic>> _serviceOptions = [
    {'id': 'DOCTOR', 'icon': Icons.medical_services_rounded},
    {'id': 'NURSE', 'icon': Icons.health_and_safety_rounded},
    {'id': 'AMBULANCE', 'icon': Icons.local_shipping_rounded},
  ];

  String _getServiceLabel(String id, AppLocalizations l10n) {
    if (id == 'DOCTOR') return l10n.doctor;
    if (id == 'NURSE') return l10n.nurse;
    if (id == 'AMBULANCE') return l10n.ambulance;
    return id;
  }

  void _submit() async {
    if (_selectedService == null) return;

    String finalSpecialty = '';
    String? ambulanceType;

    if (_selectedService == 'DOCTOR') {
      finalSpecialty = _selectedSpecialty?.toJson() ?? '';
    } else if (_selectedService == 'NURSE') {
      finalSpecialty = Specialty.soinsADomicile.toJson();
    } else if (_selectedService == 'AMBULANCE') {
      ambulanceType = _selectedAmbulanceTypes.map((e) => e.toJson()).join(',');
    }

    try {
      // Dans MSD profile_provider, updatePersonalInfo gère aussi les champs pro
      final profile = ref.read(profileProvider).userProfile;
      if (profile == null) return;

      await ref.read(profileProvider.notifier).updatePersonalInfo(
        firstName: profile.firstName ?? '',
        lastName: profile.lastName ?? '',
        phoneNumber: profile.phoneNumber ?? '',
        address: profile.address ?? '',
        city: profile.city ?? '',
        serviceType: _selectedService,
        specialty: finalSpecialty,
        ambulanceType: ambulanceType,
      );

      if (!mounted) return;
      
      final pro = ref.read(profileProvider).proProfile;
      if (pro != null) {
        if (!pro.hasUploadedDocuments) {
          context.go('/profile/pro-upload');
        } else if (pro.status == ValidationStatus.PENDING) {
          context.go('/profile/pro-waiting');
        } else if (pro.status == ValidationStatus.REJECTED) {
          context.go('/profile/pro-rejected');
        } else {
          context.go('/pro-home');
        }
      } else {
        context.go('/pro-home');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileState = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(l10n.profileSetup ?? 'Configuration Profil', style: const TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.completeProProfile ?? 'Complétez votre profil professionnel',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.proSetupSubtitle ?? 'Choisissez votre métier et votre spécialité.',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            Text(
              (l10n.occupation ?? 'Votre métier').toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            _buildServiceGrid(l10n, isDark),
            
            if (_selectedService != null) ...[
              const SizedBox(height: 32),
              Text(
                (l10n.specialty ?? 'Spécialisation').toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2, color: AppTheme.primary),
              ),
              const SizedBox(height: 16),
              _buildServiceDetails(l10n, isDark),
            ],
            
            const SizedBox(height: 48),
            MsdButton(
              text: l10n.confirm,
              onPressed: _selectedService != null ? _submit : null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGrid(AppLocalizations l10n, bool isDark) {
    return Column(
      children: _serviceOptions.map((opt) {
        final isSelected = _selectedService == opt['id'];
        return GestureDetector(
          onTap: () => setState(() {
            _selectedService = opt['id'];
            _selectedSpecialty = null;
            _selectedAmbulanceTypes.clear();
          }),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? AppTheme.primary : (isDark ? Colors.white10 : Colors.grey.shade200)),
              boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
            ),
            child: Row(
              children: [
                Icon(opt['icon'], color: isSelected ? Colors.white : AppTheme.primary, size: 28),
                const SizedBox(width: 16),
                Text(
                  _getServiceLabel(opt['id'], l10n),
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold, 
                    color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87)
                  ),
                ),
                const Spacer(),
                if (isSelected) const Icon(Icons.check_circle, color: Colors.white),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServiceDetails(AppLocalizations l10n, bool isDark) {
    if (_selectedService == 'DOCTOR') {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        ),
        child: DropdownButtonFormField<Specialty>(
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            hintText: l10n.chooseSpecialty,
            prefixIcon: const Icon(Icons.stars_rounded, color: AppTheme.primary),
          ),
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          value: _selectedSpecialty,
          items: Specialty.values.where((s) => s != Specialty.soinsADomicile).map((spec) {
            return DropdownMenuItem(value: spec, child: Text(spec.getLabel(l10n)));
          }).toList(),
          onChanged: (val) => setState(() => _selectedSpecialty = val),
        ),
      );
    } else if (_selectedService == 'NURSE') {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${l10n.specialty} : ${Specialty.soinsADomicile.getLabel(l10n)}',
                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      );
    } else if (_selectedService == 'AMBULANCE') {
      return Column(
        children: AmbulanceType.values.map((type) {
          final isChecked = _selectedAmbulanceTypes.contains(type);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isChecked ? AppTheme.primary : (isDark ? Colors.white10 : Colors.grey.shade200)),
            ),
            child: CheckboxListTile(
              title: Text(type.getLabel(l10n), style: const TextStyle(fontWeight: FontWeight.w500)),
              value: isChecked,
              activeColor: AppTheme.primary,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedAmbulanceTypes.add(type);
                  } else {
                    _selectedAmbulanceTypes.remove(type);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }
}
