import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/msd_button.dart';
import '../../../shared/widgets/msd_text_field.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class CompletePersonalInfoScreen extends ConsumerStatefulWidget {
  const CompletePersonalInfoScreen({super.key});

  @override
  ConsumerState<CompletePersonalInfoScreen> createState() => _CompletePersonalInfoScreenState();
}

class _CompletePersonalInfoScreenState extends ConsumerState<CompletePersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(profileProvider).userProfile;
      if (user != null) {
        _phoneController.text = user.phoneNumber ?? '';
        _addressController.text = user.address ?? '';
        _cityController.text = user.city ?? '';
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _navigateToNextStep() {
    final authRole = ref.read(authProvider).userRole;
    final profile = ref.read(profileProvider).userProfile;
    
    // Détection robuste du rôle : Priorité Patient
    final bool isPatient = authRole == 'patient' || (profile != null && !profile.isProfessional);

    if (isPatient) {
      context.go('/profile/medical-info');
    } else {
      context.go('/profile/pro-setup');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final profile = ref.read(profileProvider).userProfile;
      if (profile == null) throw Exception('Profil non chargé');

      await ref.read(profileProvider.notifier).updatePersonalInfo(
        firstName: profile.firstName ?? '',
        lastName: profile.lastName ?? '',
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
      );
      
      if (!mounted) return;
      _navigateToNextStep();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final profile = ref.watch(profileProvider).userProfile;
    final authRole = ref.watch(authProvider).userRole;
    
    // Pour forcer la saisie, on rend les champs obligatoires
    final bool isPatient = authRole == 'patient' || (profile != null && !profile.isProfessional);
    final bool isProfessional = !isPatient && (authRole == 'professional' || (profile?.isProfessional == true));

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Suppression du bouton Skip dans actions
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.profileSetup,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.proSetupSubtitle,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              MsdTextField(
                label: l10n.phone,
                hint: '06XXXXXXXX',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Le numéro de téléphone est requis';
                  if (value.length < 10) return 'Numéro invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              MsdTextField(
                label: l10n.city,
                hint: 'Ex: Agadir',
                controller: _cityController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'La ville est requise';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              MsdTextField(
                label: l10n.address,
                hint: 'Ex: Hay Salam, N 10',
                controller: _addressController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'L\'adresse est requise';
                  return null;
                },
              ),
              const SizedBox(height: 48),
              MsdButton(
                text: l10n.continueText,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
