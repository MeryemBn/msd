import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../models/medical_record.dart';
import '../../sos/shared/models/sos_enums.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;

  // Professional fields
  String? _selectedServiceType;
  String? _selectedSpecialty;
  List<String> _selectedAmbulanceTypes = [];

  // Patient fields
  String? _selectedBloodType;
  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  List<String> _tempAllergies = [];
  List<String> _tempHistory = [];

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider).userProfile;

    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _phoneController = TextEditingController(text: user?.phoneNumber);
    _addressController = TextEditingController(text: user?.address);
    _cityController = TextEditingController(text: user?.city);

    // Initialisation Pro
    _selectedServiceType = user?.serviceType?.toUpperCase();
    _selectedSpecialty = user?.specialty;

    if (user?.ambulanceType != null && user!.ambulanceType!.isNotEmpty) {
      _selectedAmbulanceTypes = user.ambulanceType!
          .split(',')
          .map((e) => e.trim().toUpperCase())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    // Initialisation Patient
    final records = user?.medicalRecords ?? [];
    final bloodRecord = records.where((r) => r.type == 'BLOOD_TYPE').firstOrNull;
    _selectedBloodType = bloodRecord?.description;

    _tempAllergies = records.where((r) => r.type == 'ALLERGY').map((r) => r.description).toList();
    _tempHistory = records.where((r) => r.type == 'MEDICAL_HISTORY').map((r) => r.description).toList();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(profileProvider.notifier);
    final user = ref.read(profileProvider).userProfile;
    final authState = ref.read(authProvider);
    final String? authRole = authState.userRole;

    // Détection de rôle robuste
    final bool isAdmin = authRole == 'admin';
    final bool isPatient = authRole == 'patient';
    final bool isPro = authRole == 'professional' || (user?.isProfessional == true && !isPatient && !isAdmin);

    String? ambulanceTypeStr = _selectedAmbulanceTypes.isNotEmpty
        ? _selectedAmbulanceTypes.join(', ')
        : "";

    await notifier.updatePersonalInfo(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      serviceType: isPro ? _selectedServiceType : null,
      specialty: isPro ? (_selectedServiceType == 'DOCTOR' ? _selectedSpecialty : null) : null,
      ambulanceType: isPro ? (_selectedServiceType == 'AMBULANCE' ? ambulanceTypeStr : "") : null,
    );

    // Records médicaux (uniquement si patient)
    if (isPatient) {
      final existingRecords = user?.medicalRecords ?? [];

      // Sync Blood Type
      if (_selectedBloodType != null) {
        final old = existingRecords.where((r) => r.type == 'BLOOD_TYPE').firstOrNull;
        if (old == null || old.description != _selectedBloodType) {
          if (old != null) await notifier.deleteMedicalRecord(old.id!);
          await notifier.addMedicalRecord('BLOOD_TYPE', _selectedBloodType!);
        }
      }
    }

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileUpdatedSuccess)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(profileProvider).userProfile;
    final authState = ref.watch(authProvider);
    final String? authRole = authState.userRole;
    
    // Détection de rôle robuste
    final bool isAdmin = authRole == 'admin';
    final bool isPatient = authRole == 'patient';
    final bool isPro = authRole == 'professional' || (user?.isProfessional == true && !isPatient && !isAdmin);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.editProfile, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _saveProfile(l10n),
            child: Text(l10n.save, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(l10n.personalInfo),
              _buildTextField(l10n.firstName, _firstNameController),
              _buildTextField(l10n.lastName, _lastNameController),
              _buildTextField(l10n.phone, _phoneController, keyboardType: TextInputType.phone),
              _buildTextField(l10n.address, _addressController),
              _buildTextField(l10n.city, _cityController),

              if (isPro) ...[
                const SizedBox(height: 32),
                _buildSectionTitle(l10n.professionalInfo),

                _buildLabel(l10n.serviceType),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedServiceType,
                  dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                  decoration: _inputDecoration(context),
                  items: [
                    DropdownMenuItem(value: 'DOCTOR', child: Text(l10n.doctor)),
                    DropdownMenuItem(value: 'NURSE', child: Text(l10n.nurse)),
                    DropdownMenuItem(value: 'AMBULANCE', child: Text(l10n.ambulance)),
                  ],
                  onChanged: (v) => setState(() {
                    _selectedServiceType = v;
                    _selectedSpecialty = null;
                    _selectedAmbulanceTypes = [];
                  }),
                ),

                if (_selectedServiceType == 'DOCTOR') ...[
                  const SizedBox(height: 16),
                  _buildLabel(l10n.specialty),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: _selectedSpecialty,
                    dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                    decoration: _inputDecoration(context, l10n.chooseSpecialty),
                    items: Specialty.values
                        .where((s) => s != Specialty.soinsADomicile)
                        .map((s) => DropdownMenuItem(value: s.toJson(), child: Text(s.getLabel(l10n))))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSpecialty = v),
                  ),
                ] else if (_selectedServiceType == 'AMBULANCE') ...[
                  const SizedBox(height: 16),
                  _buildLabel(l10n.ambulanceType),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: AmbulanceType.values.map((type) {
                      final typeKey = type.toJson();
                      final isSelected = _selectedAmbulanceTypes.contains(typeKey);
                      return FilterChip(
                        label: Text(type.getLabel(l10n)),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              if (!_selectedAmbulanceTypes.contains(typeKey)) {
                                _selectedAmbulanceTypes.add(typeKey);
                              }
                            } else {
                              _selectedAmbulanceTypes.remove(typeKey);
                            }
                          });
                        },
                        selectedColor: AppTheme.primary.withOpacity(0.2),
                        checkmarkColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: isSelected ? AppTheme.primary : Colors.grey.shade300),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? AppTheme.primary : AppTheme.textGrey,
                        ),
                      );
                    }).toList(),
                  ),
                ] else if (_selectedServiceType == 'NURSE') ...[
                  const SizedBox(height: 16),
                  _buildFixedInfoTile(l10n.specialty, l10n.homeCare),
                ],
              ],

              if (isPatient) ...[
                const SizedBox(height: 32),
                _buildSectionTitle(l10n.medicalInfo),
                _buildLabel(l10n.bloodGroup),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _selectedBloodType,
                  dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
                  decoration: _inputDecoration(context),
                  items: _bloodTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _selectedBloodType = v),
                ),
                const SizedBox(height: 24),
                _buildDynamicList(l10n.allergies, _tempAllergies, 'ALLERGY', l10n),
                const SizedBox(height: 24),
                _buildDynamicList(l10n.medicalHistory, _tempHistory, 'MEDICAL_HISTORY', l10n),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 1)),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.textGrey)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: _inputDecoration(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedInfoTile(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1)),
          ),
          child: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context, [String? hint]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
    );
  }

  Widget _buildDynamicList(String title, List<String> items, String type, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.textGrey)),
            IconButton(
              onPressed: () => _showAddDialog(title, type, l10n),
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
            ),
          ],
        ),
        if (items.isEmpty)
          Text(l10n.noneProvided, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
        else
          Wrap(
            spacing: 8,
            children: items.map((item) => Chip(
              label: Text(item),
              onDeleted: () {
                setState(() {
                  if (type == 'ALLERGY') {
                    _tempAllergies.remove(item);
                  } else {
                    _tempHistory.remove(item);
                  }
                });
              },
            )).toList(),
          ),
      ],
    );
  }

  void _showAddDialog(String title, String type, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addTitle(title)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.description),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  if (type == 'ALLERGY') {
                    _tempAllergies.add(controller.text);
                  } else {
                    _tempHistory.add(controller.text);
                  }
                });
              }
              Navigator.pop(context);
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }
}
