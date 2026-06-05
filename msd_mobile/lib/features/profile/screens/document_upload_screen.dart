import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/app_theme.dart';
import '../../../core/network/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/msd_button.dart';
import '../providers/profile_provider.dart';
import '../services/ocr_service.dart';

class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final Map<String, File?> _documents = {};
  final Map<String, String?> _ocrData = {};
  final Map<String, String?> _docErrors = {};
  bool _isUploading = false;
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDocumentMap();
    });
  }

  void _initDocumentMap() {
    final proProfile = ref.read(profileProvider).proProfile;
    final proType = proProfile?.type?.toUpperCase();
    
    setState(() {
      _documents['CNI_FRONT'] = null;
      _documents['CNI_BACK'] = null;
      _documents['DIPLOMA'] = null;
      _documents['AUTHORIZATION'] = null;
      
      if (proType == 'AMBULANCE' || proType == 'AMBULANCIER') {
        _documents['VEHICLE_REGISTRATION'] = null;
        _documents['TRANSPORT_AUTHORIZATION'] = null;
      }
    });
  }

  Future<void> _pickImage(String type) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Sélectionnez la source",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: "Appareil photo",
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                _buildSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: "Galerie",
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
    if (image != null) {
      final file = File(image.path);
      final profile = ref.read(profileProvider).userProfile;
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)), 
            SizedBox(width: 12), 
            Expanded(child: Text("Vérification OCR en cours...", style: TextStyle(color: Colors.white)))
          ]), 
          duration: Duration(seconds: 2)
        ),
      );

      final result = await ocrService.processDocument(
        imageFile: file,
        docType: type,
        userFirstName: profile?.firstName ?? '',
        userLastName: profile?.lastName ?? '',
        expectedSpecialty: profile?.specialty,
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (!result.success) {
        setState(() {
          _documents[type] = null;
          _docErrors[type] = result.errorMessage;
        });
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 10),
                Expanded(child: Text("Document Invalide")),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Le document a été refusé :", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(result.errorMessage ?? "Anomalie détectée.", style: const TextStyle(color: Colors.red, fontSize: 13)),
                const SizedBox(height: 16),
                const Text("Veuillez fournir un document valide."),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Réessayer"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _documents[type] = file;
          _docErrors[type] = null;
          _ocrData[type] = result.structuredReport;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Document validé !"), backgroundColor: Colors.green),
        );
      }
    }
  }

  Widget _buildSourceOption({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  bool _isStepValid(int step) {
    if (step == 1) {
      return _documents['CNI_FRONT'] != null &&
             _documents['CNI_BACK'] != null &&
             _documents['DIPLOMA'] != null &&
             _documents['AUTHORIZATION'] != null;
    } else {
      return _documents['VEHICLE_REGISTRATION'] != null &&
             _documents['TRANSPORT_AUTHORIZATION'] != null;
    }
  }

  Future<void> _submit() async {
    setState(() => _isUploading = true);

    try {
      final client = ref.read(apiClientProvider);
      for (var entry in _documents.entries) {
        if (entry.value != null) {
          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(entry.value!.path),
            'type': entry.key,
            'ocrResult': _ocrData[entry.key] ?? '',
          });

          await client.dio.post('/api/profiles/me/documents', data: formData);
        }
      }

      if (!mounted) return;
      await ref.read(profileProvider.notifier).loadProfile();
      context.go('/profile/pro-waiting');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final proProfile = ref.watch(profileProvider).proProfile;
    final proType = proProfile?.type?.toUpperCase();
    final isAmbulance = proType == 'AMBULANCE' || proType == 'AMBULANCIER';
    final totalSteps = isAmbulance ? 2 : 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verificationDocs),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Étape $_currentStep sur $totalSteps',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    _currentStep == 1 ? 'Documents Professionnels' : 'Documents Véhicule',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _currentStep / totalSteps,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 32),
            
            if (_currentStep == 1) ...[
              const Text(
                'Identité & Diplômes',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Vérification OCR du nom et de la nature du document.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _buildDocTile('CNI_FRONT', l10n.cniFront, Icons.badge_outlined),
              const SizedBox(height: 16),
              _buildDocTile('CNI_BACK', l10n.cniBack, Icons.badge_outlined),
              const SizedBox(height: 16),
              _buildDocTile('DIPLOMA', l10n.diploma, Icons.school_outlined),
              const SizedBox(height: 16),
              _buildDocTile('AUTHORIZATION', l10n.authorization, Icons.assignment_ind_outlined),
            ] else ...[
              const Text(
                'Informations Véhicule',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Vérification de la carte grise et des permis.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _buildDocTile('VEHICLE_REGISTRATION', l10n.vehicleRegistration, Icons.directions_car_outlined),
              const SizedBox(height: 16),
              _buildDocTile('TRANSPORT_AUTHORIZATION', l10n.transportAuth, Icons.local_shipping_outlined),
            ],
            
            const SizedBox(height: 48),
            MsdButton(
              text: _currentStep < totalSteps ? l10n.next : 'Envoyer pour vérification',
              isLoading: _isUploading,
              onPressed: _isStepValid(_currentStep) 
                ? () {
                    if (_currentStep < totalSteps) {
                      setState(() => _currentStep++);
                    } else {
                      _submit();
                    }
                  }
                : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocTile(String type, String label, IconData icon) {
    final file = _documents[type];
    final error = _docErrors[type];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _pickImage(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: error != null ? Colors.red : (file != null ? AppTheme.primary : (isDark ? Colors.white10 : Colors.grey.shade300)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              error != null ? Icons.error_outline : icon, 
              color: error != null ? Colors.red : (file != null ? AppTheme.primary : Colors.grey)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                  if (file != null)
                    const Text('Vérifié & Validé', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold))
                  else if (error != null)
                    Text(error, style: const TextStyle(color: Colors.red, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis)
                  else
                    const Text('Scanner ou choisir une photo', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (file != null)
              const Icon(Icons.check_circle, color: Colors.green)
            else if (error != null)
              const Icon(Icons.warning, color: Colors.red)
            else
              const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
