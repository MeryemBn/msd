import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import '../../sos/shared/models/sos_request.dart';
import '../../sos/shared/models/sos_enums.dart';
import '../../sos/shared/models/request_details.dart';
import '../providers/professional_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../app/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/services/location_service.dart';

class ProRequestDetailSheet extends ConsumerStatefulWidget {
  final SosRequest request;
  const ProRequestDetailSheet({super.key, required this.request});

  @override
  ConsumerState<ProRequestDetailSheet> createState() => _ProRequestDetailSheetState();
}

class _ProRequestDetailSheetState extends ConsumerState<ProRequestDetailSheet> {
  Timer? _refreshTimer;
  String _distanceLabel = "--";

  @override
  void initState() {
    super.initState();
    _fetchRoadDistance();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _fetchRoadDistance();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRoadDistance() async {
    final proPos = ref.read(professionalProvider).currentPosition;
    final patientLoc = widget.request.details.interventionDetails.location;
    
    if (proPos == null || patientLoc == null) return;

    final origin = maps.LatLng(proPos.latitude, proPos.longitude);
    final destination = maps.LatLng(patientLoc.latitude, patientLoc.longitude);
    
    final routeData = await locationService.getRouteData(origin, destination);
    
    if (mounted && routeData != null) {
      setState(() {
        _distanceLabel = routeData.distanceText;
      });
    }
  }

  bool _canJoinMeeting() {
    final appointmentTime = widget.request.details.interventionDetails.appointmentDateTime;
    if (appointmentTime == null) return true;
    final now = DateTime.now();
    final allowedStartTime = appointmentTime.subtract(const Duration(minutes: 5));
    return now.isAfter(allowedStartTime);
  }

  Future<void> _joinCall(BuildContext context, WidgetRef ref) async {
    final status = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (status[Permission.camera]!.isGranted &&
        status[Permission.microphone]!.isGranted) {
      final user = ref.read(profileProvider).userProfile;
      if (context.mounted) {
        context.push('/teleconsult-call', extra: {
          'roomName': widget.request.roomName ?? 'MSD_Teleconsult_${widget.request.id}',
          'jwt': widget.request.jitsiToken,
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
    final l10n = AppLocalizations.of(context)!;
    final proState = ref.watch(professionalProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAppointment = widget.request.details.interventionDetails.interventionType == InterventionType.appointment;
    final appointmentDt = widget.request.details.interventionDetails.appointmentDateTime;
    final isAlreadyAccepted = widget.request.status != RequestStatus.pending;
    final isTeleconsult = widget.request.details is TeleconsultDetails;
    final now = DateTime.now();

    final bool isLate = isAppointment && 
                        widget.request.status == RequestStatus.confirmed &&
                        appointmentDt != null && 
                        now.isAfter(appointmentDt.add(const Duration(minutes: 30)));

    final Color primaryColor = isLate ? AppTheme.orangeAccent : AppTheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: isLate ? Border.all(color: AppTheme.orangeAccent, width: 2) : null,
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            _buildHeader(context, isAppointment, isTeleconsult, primaryColor, isLate),
            const SizedBox(height: 24),
            _buildStatusBadge(context, widget.request.status, primaryColor, isLate),
            const Divider(),
            const SizedBox(height: 24),
            if (isAppointment && appointmentDt != null) ...[
              _buildDetailItem(Icons.calendar_today, l10n.appointment,
                  DateFormat('EEEE dd MMMM yyyy', Localizations.localeOf(context).languageCode).format(appointmentDt)),
              _buildDetailItem(Icons.access_time, l10n.time, DateFormat('HH:mm').format(appointmentDt), 
                  valueColor: isLate ? AppTheme.orangeAccent : null, 
                  isBold: isLate),
              const SizedBox(height: 16),
            ],
            if (!isTeleconsult) ...[
              _buildDetailItem(Icons.location_on_outlined, l10n.address,
                  widget.request.details.interventionDetails.location?.address ?? l10n.addressNotSpecified),
              _buildDetailItem(Icons.straighten, "Distance", _distanceLabel),
            ],
            _buildDetailItem(Icons.payment, l10n.payment, widget.request.paymentMethod.getLabel(l10n)),
            const SizedBox(height: 32),
            _buildFooterActions(context, ref, l10n, isAlreadyAccepted, isAppointment, isTeleconsult, proState, isLate),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isAppointment, bool isTeleconsult, Color color, bool isLate) {
    // Le prix n'est affiché que si la demande n'est plus en attente
    final bool showPrice = widget.request.status != RequestStatus.pending;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isAppointment ? (isTeleconsult ? Icons.videocam : Icons.event_available) : Icons.person_outline,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.request.patientFullName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                _getServiceLabel(context, widget.request.details),
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (showPrice)
          Text(
            "${widget.request.price.toStringAsFixed(0)} MAD",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
      ],
    );
  }

  Widget _buildFooterActions(BuildContext context, WidgetRef ref, AppLocalizations l10n, bool isAlreadyAccepted, bool isAppointment, bool isTeleconsult, ProfessionalState proState, bool isLate) {
    if (!isAlreadyAccepted) {
      return Column(
        children: [
          _FullWidthButton(
            label: l10n.confirm,
            onTap: () async {
              try {
                await ref.read(professionalProvider.notifier).acceptRequest(widget.request);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (e.toString().contains("CONFLIT_HORAIRE")) {
                   _showErrorSnackBar(context, l10n.scheduleConflict);
                } else if (e.toString().toLowerCase().contains("already accepted by another")) {
                   _showErrorSnackBar(context, l10n.requestAlreadyTaken);
                } else {
                   _showErrorSnackBar(context, e.toString());
                }
              }
            },
          ),
          if (isAppointment) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  try {
                    await ref.read(professionalProvider.notifier).rejectRequest(widget.request.id!);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    _showErrorSnackBar(context, e.toString());
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Rejeter", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      );
    }

    if (widget.request.status == RequestStatus.completed || widget.request.status == RequestStatus.cancelled || widget.request.status == RequestStatus.rejected) {
      return const SizedBox.shrink();
    }

    final bool isOnTheWay = widget.request.status == RequestStatus.on_the_way;
    final bool isInProgress = widget.request.status == RequestStatus.in_progress;
    final bool isAwaitingPayment = widget.request.status == RequestStatus.awaiting_payment;

    return Column(
      children: [
        if (isAwaitingPayment)
           _FullWidthButton(
            label: "EN ATTENTE DU PAIEMENT PATIENT",
            enabled: false,
            onTap: () {},
            color: Colors.orange.shade300,
          )
        else if (widget.request.status == RequestStatus.confirmed)
          _buildStartButton(context, ref, l10n, isTeleconsult, proState, isLate)
        else if (isOnTheWay || isInProgress) ...[
          if (isTeleconsult && isInProgress) ...[
             _FullWidthButton(
              label: l10n.join.toUpperCase(),
              icon: Icons.videocam,
              onTap: () => _joinCall(context, ref),
            ),
            const SizedBox(height: 12),
          ],
          _FullWidthButton(
            label: l10n.done.toUpperCase(),
            onTap: () => _showFinishDialog(context, ref, l10n),
          ),
        ],

        if (!isOnTheWay && !isInProgress && !isAwaitingPayment) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showCancelMissionDialog(context, ref, widget.request, l10n),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.cancel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref, AppLocalizations l10n, bool isTeleconsult, ProfessionalState proState, bool isLate) {
    final bool canStart = _canJoinMeeting();
    String label = isTeleconsult ? l10n.join : l10n.start;

    return _FullWidthButton(
      label: label.toUpperCase(),
      enabled: canStart,
      color: isLate ? AppTheme.orangeAccent : null,
      onTap: () async {
        if (!canStart) {
           _showErrorSnackBar(context, l10n.tooEarlyForAppointment);
           return;
        }
        if (proState.activeMission != null && proState.activeMission!.id != widget.request.id) {
          _showErrorSnackBar(context, l10n.alreadyActiveMission);
          return;
        }

        try {
          final nextStatus = isTeleconsult ? RequestStatus.in_progress : RequestStatus.on_the_way;
          await ref.read(professionalProvider.notifier).updateStatus(nextStatus, requestId: widget.request.id);
          
          if (isTeleconsult) {
            if (context.mounted) {
              await _joinCall(context, ref);
            }
          }

          if (context.mounted) Navigator.pop(context);
        } catch (e) {
          _showErrorSnackBar(context, e.toString());
        }
      },
    );
  }

  Widget _buildStatusBadge(BuildContext context, RequestStatus status, Color color, bool isLate) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(_getStatusIcon(status), color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("STATUT", style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                Text(status.getLabel(l10n).toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
          ),
          if (isLate)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.orangeAccent, borderRadius: BorderRadius.circular(8)),
              child: Text(
                l10n.appointmentLate.toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending: return Icons.hourglass_top_rounded;
      case RequestStatus.awaiting_payment: return Icons.hourglass_bottom_rounded;
      case RequestStatus.confirmed: return Icons.check_circle_rounded;
      case RequestStatus.on_the_way: return Icons.local_shipping_rounded;
      case RequestStatus.in_progress: return Icons.videocam_rounded;
      case RequestStatus.completed: return Icons.verified_rounded;
      case RequestStatus.cancelled: return Icons.cancel_rounded;
      case RequestStatus.rejected: return Icons.block;
    }
  }

  String _getServiceLabel(BuildContext context, dynamic details) {
    final l10n = AppLocalizations.of(context)!;
    if (details is DoctorDetails) return l10n.inPersonConsultation;
    if (details is TeleconsultDetails) return l10n.teleconsultation;
    if (details is NurseDetails) return l10n.homeCare;
    if (details is AmbulanceDetails) return details.ambulanceType.getLabel(l10n);
    return details.interventionDetails.interventionType == InterventionType.sos_urgency ? "SOS Urgence" : l10n.appointment;
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showFinishDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.statusCompleted),
        content: const Text("Confirmez-vous que l'intervention est terminée ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              ref.read(professionalProvider.notifier).updateStatus(RequestStatus.completed);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showCancelMissionDialog(BuildContext context, WidgetRef ref, SosRequest request, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cancelRequestConfirmTitle),
        content: Text(l10n.cancelRequestConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              ref.read(professionalProvider.notifier).updateStatus(RequestStatus.cancelled, requestId: request.id);
            },
            child: Text(l10n.confirm, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(
                fontSize: 15, 
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                color: valueColor,
              )),
            ]),
          ),
        ],
      ),
    );
  }
}

class _FullWidthButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool enabled;
  final Color? color;

  const _FullWidthButton({required this.label, required this.onTap, this.icon, this.enabled = true, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: enabled && color == null ? const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ) : null,
        color: enabled ? (color ?? null) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
