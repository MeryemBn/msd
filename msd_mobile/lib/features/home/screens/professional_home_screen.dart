import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import '../providers/professional_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/pro_status_toggle.dart';
import '../widgets/active_mission_card.dart';
import '../widgets/proximity_request_tile.dart';
import '../widgets/pro_request_detail_sheet.dart';
import '../../profile/providers/profile_provider.dart';
import '../../sos/shared/models/sos_enums.dart';
import '../../sos/shared/models/sos_request.dart';
import '../../sos/shared/models/request_details.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../core/services/location_service.dart';

class ProfessionalHomeScreen extends ConsumerStatefulWidget {
  const ProfessionalHomeScreen({super.key});

  @override
  ConsumerState<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends ConsumerState<ProfessionalHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(professionalProvider.notifier).refreshAll();
    });
  }

  String _getServiceLabel(BuildContext context, RequestDetails details) {
    final l10n = AppLocalizations.of(context)!;
    if (details is TeleconsultDetails) return l10n.teleconsultation;
    if (details is DoctorDetails) return l10n.doctor;
    if (details is NurseDetails) return l10n.nurse;
    if (details is AmbulanceDetails) return l10n.ambulance;
    return "SOS";
  }

  Future<void> _joinCall(BuildContext context, SosRequest request) async {
    final status = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (status[Permission.camera]!.isGranted &&
        status[Permission.microphone]!.isGranted) {
      final user = ref.read(profileProvider).userProfile;
      if (context.mounted) {
        context.push('/teleconsult-call', extra: {
          'roomName': request.roomName ?? 'MSD_Teleconsult_${request.id}',
          'jwt': request.jitsiToken,
          'displayName': user?.fullName ?? 'Professionnel',
          'email': user?.email,
        });
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Accès caméra et micro requis")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final proState = ref.watch(professionalProvider);
    final user = ref.watch(profileProvider).userProfile;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(professionalProvider.notifier).refreshAll();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(context, user, proState),
                const SizedBox(height: 20),

                // 1. Mission active
                if (proState.activeMission != null) ...[
                  _buildSectionTitle(l10n.missionInProgress.toUpperCase(), isDark ? Colors.white : Colors.black),
                  const SizedBox(height: 10),
                  ActiveMissionCard(
                    requestId: proState.activeMission!.id ?? "---",
                    patientName: proState.activeMission!.patientFullName,
                    patientPhoneNumber: proState.activeMission!.patientPhoneNumber ?? "",
                    serviceDetails: _getServiceLabel(context, proState.activeMission!.details),
                    address: proState.activeMission!.details.interventionDetails.location?.address ?? l10n.addressNotSpecified,
                    price: "${proState.activeMission!.price.toStringAsFixed(0)} MAD",
                    status: proState.activeMission!.status,
                    patientLat: proState.activeMission!.details.interventionDetails.location?.latitude,
                    patientLng: proState.activeMission!.details.interventionDetails.location?.longitude,
                    proPosition: proState.currentPosition,
                    isTeleconsult: proState.activeMission!.details is TeleconsultDetails,
                    appointmentDateTime: proState.activeMission!.details.interventionDetails.appointmentDateTime,
                    onAction: () => _handleMissionAction(context, proState.activeMission!, l10n),
                    onJoinCall: () => _joinCall(context, proState.activeMission!),
                    onTap: () => _showRequestDetails(context, proState.activeMission!),
                    onItinerary: () {
                      final loc = proState.activeMission!.details.interventionDetails.location;
                      if (loc != null) {
                        locationService.launchDirections(loc.latitude, loc.longitude);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // 2. Section Urgences
                _buildSectionTitle(l10n.emergenciesTitle.toUpperCase(), isDark ? Colors.white : Colors.black),
                const SizedBox(height: 8),
                _buildRequestList(
                  context: context,
                  requests: proState.nearbyUrgencies,
                  emptyMsg: proState.isOnline ? l10n.noEmergencyNearby : "Activez votre disponibilité",
                  proState: proState,
                ),
                const SizedBox(height: 24),

                // 3. Section Rendez-vous en attente
                _buildSectionTitle(l10n.appointmentsTitle.toUpperCase(), isDark ? Colors.white : Colors.black),
                const SizedBox(height: 8),
                _buildRequestList(
                  context: context,
                  requests: proState.pendingDirectAppointments,
                  emptyMsg: l10n.noAppointmentsAssigned,
                  proState: proState,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleMissionAction(BuildContext context, SosRequest mission, AppLocalizations l10n) async {
    final currentStatus = mission.status;
    if (currentStatus == RequestStatus.on_the_way || currentStatus == RequestStatus.in_progress) {
      _showFinishDialog(context, l10n);
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user, proState) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rating = user?.averageRating ?? 0.0;
    final reviewsCount = user?.totalReviews ?? 0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${l10n.hello} 👋", style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(
                user?.fullName ?? l10n.professional,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
              ),
              if (reviewsCount > 0)
                GestureDetector(
                  onTap: () => context.push('/professional/reviews'),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 22), // Plus grande
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // Plus grande
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "($reviewsCount avis)",
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 14), // Plus grande
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppTheme.textGrey, size: 20),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const _NotificationIcon(),
        const SizedBox(width: 12),
        ProStatusToggle(
          value: proState.isOnline,
          onChanged: (val) async {
            try {
              await ref.read(professionalProvider.notifier).toggleStatus(val);
            } catch (e) {
              _showErrorSnackBar(context, "Erreur: $e");
            }
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildRequestList({
    required BuildContext context,
    required List<SosRequest> requests,
    required String emptyMsg,
    required ProfessionalState proState,
    bool hideStatus = false,
  }) {
    if (proState.isLoading && requests.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
    }

    if (requests.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.withOpacity(0.5), size: 16),
            const SizedBox(width: 8),
            Text(
              emptyMsg,
              style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final request = requests[index];
        final isConfirmed = request.status == RequestStatus.confirmed;

        return ProximityRequestTile(
          request: request,
          proPosition: proState.currentPosition,
          hideStatus: hideStatus,
          onTap: () => _showRequestDetails(context, request),
          onAccept: !isConfirmed ? () {
            ref.read(professionalProvider.notifier).acceptRequest(request).catchError((e) {
              if (e.toString().contains("CONFLIT_HORAIRE")) {
                _showErrorSnackBar(context, AppLocalizations.of(context)!.scheduleConflict);
              } else {
                _showErrorSnackBar(context, "Erreur: $e");
              }
            });
          } : null,
          onStart: isConfirmed ? () async {
            if (proState.activeMission != null && proState.activeMission!.id != request.id) {
              _showErrorSnackBar(context, AppLocalizations.of(context)!.alreadyActiveMission);
              return;
            }
            
            if (request.details is TeleconsultDetails) {
              try {
                await ref.read(professionalProvider.notifier).updateStatus(RequestStatus.in_progress, requestId: request.id);
                if (mounted) {
                   _joinCall(context, request);
                }
              } catch (e) {
                _showErrorSnackBar(context, "Erreur: $e");
              }
              return;
            }

            ref.read(professionalProvider.notifier).updateStatus(RequestStatus.on_the_way, requestId: request.id).catchError((e) {
              _showErrorSnackBar(context, "Erreur: $e");
            });
          } : null,
        );
      },
    );
  }

  void _showRequestDetails(BuildContext context, SosRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProRequestDetailSheet(request: request),
    );
  }

  void _showFinishDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.statusCompleted),
        content: const Text("Confirmez-vous que l'intervention est terminée ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(professionalProvider.notifier).updateStatus(RequestStatus.completed);
            },
            child: Text(l10n.confirm, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _NotificationIcon extends ConsumerWidget {
  const _NotificationIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);
    final unreadCount = notificationState.unreadCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Stack(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.fieldBgDark : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_outlined, 
              size: 22,
              color: isDark ? Colors.white70 : AppTheme.textDark,
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.redAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF121212) : Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
