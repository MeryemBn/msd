import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_theme.dart';
import '../../sos/shared/models/sos_enums.dart';
import '../providers/profile_provider.dart';
import '../providers/revenue_provider.dart';
import '../services/pricing_service.dart';
import '../../../../l10n/app_localizations.dart';

class ProfessionalPricingScreen extends ConsumerStatefulWidget {
  const ProfessionalPricingScreen({super.key});

  @override
  ConsumerState<ProfessionalPricingScreen> createState() => _ProfessionalPricingScreenState();
}

class _ProfessionalPricingScreenState extends ConsumerState<ProfessionalPricingScreen> {
  final Map<String, TextEditingController> _priceControllers = {};
  final Map<String, TextEditingController> _kmPriceControllers = {};
  final Map<String, TextEditingController> _kmRadiusControllers = {};
  final Map<String, String?> _errors = {};
  bool _isSaving = false;
  String? _lastUserId;

  @override
  void dispose() {
    for (var c in _priceControllers.values) c.dispose();
    for (var c in _kmPriceControllers.values) c.dispose();
    for (var c in _kmRadiusControllers.values) c.dispose();
    super.dispose();
  }

  String? _normalizeValue(dynamic val) {
    if (val == null) return null;
    if (val is Specialty) return val.toJson();
    if (val is AmbulanceType) return val.toJson();
    return val.toString().toUpperCase().replaceAll(' ', '_');
  }

  void _syncControllers(List<dynamic> prices, List<Map<String, dynamic>> configs, String currentUserId) {
    if (_lastUserId != null && _lastUserId != currentUserId) {
      _priceControllers.clear();
      _kmPriceControllers.clear();
      _kmRadiusControllers.clear();
    }
    _lastUserId = currentUserId;

    for (var config in configs) {
      final key = config['key'];
      final specToMatch = _normalizeValue(config['specialty']);
      final ambToMatch = _normalizeValue(config['ambulanceType']);

      final existing = prices.firstWhere(
        (p) => p['interventionMode']?.toString().toUpperCase() == config['mode'].toString().toUpperCase() &&
               p['serviceType']?.toString().toUpperCase() == config['serviceType'].toString().toUpperCase() &&
               (specToMatch == null || p['specialty']?.toString().toUpperCase() == specToMatch.toUpperCase()) &&
               (ambToMatch == null || p['ambulanceType']?.toString().toUpperCase() == ambToMatch.toUpperCase()),
        orElse: () => null,
      );

      if (!_priceControllers.containsKey(key)) {
        _priceControllers[key] = TextEditingController();
        _kmPriceControllers[key] = TextEditingController();
        _kmRadiusControllers[key] = TextEditingController();
      }

      if (_priceControllers[key]!.text.isEmpty && existing != null) {
        _priceControllers[key]!.text = existing['price'].toString();
        _kmPriceControllers[key]!.text = (existing['extraKmPrice'] ?? 0).toString();
        _kmRadiusControllers[key]!.text = (existing['kmRadiusIncluded'] ?? 0).toString();
      }
    }
  }

  Future<void> _save(String serviceType, List<Map<String, dynamic>> configurations) async {
    setState(() => _isSaving = true);
    try {
      final pricingService = ref.read(pricingServiceProvider);
      for (var config in configurations) {
        final key = config['key'];
        final price = double.tryParse(_priceControllers[key]?.text ?? "") ?? 0;
        if (price <= 0) continue;

        final extraKmPrice = double.tryParse(_kmPriceControllers[key]?.text ?? "") ?? 0;
        final kmRadiusIncluded = int.tryParse(_kmRadiusControllers[key]?.text ?? "") ?? 0;

        // Sauvegarde du mode principal (défini dans la config)
        await pricingService.setPrice(
          serviceType: config['serviceType'],
          specialty: _normalizeValue(config['specialty']),
          ambulanceType: _normalizeValue(config['ambulanceType']),
          interventionMode: config['mode'],
          price: price,
          extraKmPrice: extraKmPrice,
          kmRadiusIncluded: kmRadiusIncluded,
        );

        // Pour les ambulances, on synchronise automatiquement RDV et Urgence
        if (config['serviceType'] == 'AMBULANCE') {
          final otherMode = config['mode'] == 'sos_urgency' ? 'appointment' : 'sos_urgency';
          await pricingService.setPrice(
            serviceType: config['serviceType'],
            specialty: _normalizeValue(config['specialty']),
            ambulanceType: _normalizeValue(config['ambulanceType']),
            interventionMode: otherMode,
            price: price,
            extraKmPrice: extraKmPrice,
            kmRadiusIncluded: kmRadiusIncluded,
          );
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Configurations enregistrées avec succès"), backgroundColor: AppTheme.primary),
        );
        ref.invalidate(professionalPricesProvider);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).userProfile;
    final pricesAsync = ref.watch(professionalPricesProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (profile == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final configs = _getConfigs(profile, l10n);

    ref.listen(professionalPricesProvider, (prev, next) {
      next.whenData((prices) => _syncControllers(prices, configs, profile.id.toString()));
    });

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F111A) : const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: const Text("PILOTAGE DES TARIFS", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        centerTitle: true,
        elevation: 0,
      ),
      body: pricesAsync.when(
        data: (prices) {
          _syncControllers(prices, configs, profile.id.toString());
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMarketInfo(),
                const SizedBox(height: 32),
                ...configs.map((config) => _buildModuleCard(config, isDark)),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 10,
                      shadowColor: AppTheme.primary.withOpacity(0.3),
                    ),
                    onPressed: _isSaving ? null : () => _save(profile.serviceType!, configs),
                    child: _isSaving 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("METTRE À JOUR MES SERVICES", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> config, bool isDark) {
    final key = config['key'];
    final error = _errors[key];
    final serviceType = config['serviceType']?.toString().toUpperCase();
    final isTeleconsult = serviceType == 'TELECONSULTATION';
    final isAmbulance = serviceType == 'AMBULANCE';
    final isUrgent = config['mode']?.toString() == 'sos_urgency';
    final bool showKmFields = !isTeleconsult && (isUrgent || isAmbulance);

    if (!_priceControllers.containsKey(key)) {
      _priceControllers[key] = TextEditingController();
      _kmPriceControllers[key] = TextEditingController();
      _kmRadiusControllers[key] = TextEditingController();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.04), blurRadius: 24, offset: const Offset(0, 12))
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: Icon(config['icon'] as IconData, color: AppTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(config['label'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.2)),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _buildInputField(
                  label: "Tarif de la consultation",
                  controller: _priceControllers[key]!,
                  isDark: isDark,
                  icon: Icons.payments_rounded,
                  error: error,
                ),
              ],
            ),
          ),
          if (showKmFields)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: "Frais / KM",
                      controller: _kmPriceControllers[key]!,
                      isDark: isDark,
                      icon: Icons.add_road_rounded,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildInputField(
                      label: "Rayon inclus",
                      controller: _kmRadiusControllers[key]!,
                      isDark: isDark,
                      icon: Icons.radar_rounded,
                      isKm: true,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required IconData icon,
    String? error,
    bool isKm = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            prefixIcon: Icon(icon, size: 18, color: error != null ? Colors.red : AppTheme.primary),
            suffixText: isKm ? "KM" : "MAD",
            filled: true,
            fillColor: isDark ? Colors.black.withOpacity(0.3) : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getConfigs(dynamic profile, AppLocalizations l10n) {
    final List<Map<String, dynamic>> c = [];
    final st = profile.serviceType?.toUpperCase();
    if (st == 'DOCTOR') {
      c.add({'key': 'D_U', 'label': l10n.sosUrgency, 'mode': 'sos_urgency', 'serviceType': 'DOCTOR', 'specialty': profile.specialty, 'icon': Icons.bolt_rounded});
      c.add({'key': 'D_R', 'label': l10n.appointment, 'mode': 'appointment', 'serviceType': 'DOCTOR', 'specialty': profile.specialty, 'icon': Icons.calendar_today_rounded});
      c.add({'key': 'D_T', 'label': l10n.teleconsultation, 'mode': 'appointment', 'serviceType': 'TELECONSULTATION', 'specialty': profile.specialty, 'icon': Icons.videocam_rounded});
    } else if (st == 'NURSE') {
      c.add({'key': 'N_U', 'label': l10n.sosUrgency, 'mode': 'sos_urgency', 'serviceType': 'NURSE', 'icon': Icons.medical_services_rounded});
      c.add({'key': 'N_R', 'label': l10n.appointment, 'mode': 'appointment', 'serviceType': 'NURSE', 'icon': Icons.event_note_rounded});
    } else if (st == 'AMBULANCE') {
      final types = (profile.ambulanceType ?? "A").toString().split(',');
      for (var t in types) {
        final typeKey = t.trim().toUpperCase();
        String label = typeKey.contains('SMUR') ? l10n.ambSmur : typeKey.contains('REANIMATION') ? l10n.ambRea : typeKey.contains('SANITAIRE') ? l10n.ambSanitary : l10n.ambVsl;
        // On n'affiche qu'une seule carte par type d'ambulance car les prix SOS et RDV sont désormais identiques
        c.add({'key': 'A_$t', 'label': label, 'mode': 'sos_urgency', 'serviceType': 'AMBULANCE', 'ambulanceType': t.trim(), 'icon': Icons.airport_shuttle_rounded});
      }
    }
    return c;
  }

  Widget _buildMarketInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.gavel_rounded, color: AppTheme.primary, size: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Liberté des Tarifs", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                Text("Déterminez vos propres tarifs selon votre expertise et la qualité de vos services.", 
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade700, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
