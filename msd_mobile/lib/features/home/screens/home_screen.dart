import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';

import '../../../app/app_theme.dart';
import '../../sos/shared/models/sos_type.dart';
import '../../sos/shared/models/sos_enums.dart';
import '../../sos/shared/models/sos_request.dart';
import '../../sos/doctor/screens/doctor_request_screen.dart';
import '../../sos/nurse/screens/nurse_request_screen.dart';
import '../../sos/ambulance/screens/ambulance_request_screen.dart';
import '../../sos/teleconsult/screens/teleconsult_request_screen.dart';
import '../providers/home_provider.dart';
import '../../sos/shared/providers/sos_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/next_dose_card.dart';
import '../widgets/sos_service_tile.dart';
import '../widgets/pharmacy_banner.dart';
import '../../sos/shared/widgets/sos_request_detail_sheet.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../../shared/widgets/section_header.dart';
import 'pharmacy_map_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider).refresh();
      // Keep SOS polling active so patients receive accept/reject notifications
      ref.read(sosProvider.notifier).loadMyRequests(silent: true);
    });
  }

  void _navigateToSos(SosType type) {
    Widget screen;
    switch (type) {
      case SosType.doctor:
        screen = const DoctorRequestScreen();
        break;
      case SosType.nurse:
        screen = const NurseRequestScreen();
        break;
      case SosType.ambulance:
        screen = const AmbulanceRequestScreen();
        break;
      case SosType.teleconsult:
        screen = const TeleconsultRequestScreen();
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = ref.watch(homeProvider);
    final state = provider.state;
    final sosState = ref.watch(sosProvider);

    if (state.isLoading && state.nextDoseInfo == null && state.userProfile == null) {
      return const Scaffold(
        body: SafeArea(child: LoadingSkeleton()),
      );
    }

    final awaitingPaymentRequests = sosState.myRequests
        .where((r) => r.status == RequestStatus.awaiting_payment)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(homeProvider).refresh();
            await ref.read(sosProvider.notifier).loadMyRequests(silent: true);
          },
          color: AppTheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                HomeHeader(
                  patientName: state.patientName,
                ),
                if (awaitingPaymentRequests.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildPaymentAlerts(awaitingPaymentRequests),
                ],
                const SizedBox(height: 24),
                const NextDoseCard(),
                const SizedBox(height: 32),
                SectionHeader(label: l10n.sosServices),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: SosType.values.map((type) {
                    return SosServiceTile(
                      type: type,
                      onTap: () => _navigateToSos(type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SectionHeader(label: l10n.onDutyPharmacy),
                const SizedBox(height: 12),
                PharmacyBanner(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PharmacyMapScreen()),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentAlerts(List<SosRequest> requests) {
    return Column(
      children: requests.map((req) => _PaymentAlertCard(request: req)).toList(),
    );
  }
}

class _PaymentAlertCard extends StatelessWidget {
  final SosRequest request;
  const _PaymentAlertCard({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.redAccent.withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => SosRequestDetailSheet(request: request),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppTheme.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "PAIEMENT REQUIS",
                        style: TextStyle(
                          color: AppTheme.redAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Votre demande a été acceptée par ${request.professionalFullName}. Payez maintenant pour confirmer l'intervention.",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppTheme.redAccent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
