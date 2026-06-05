import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import '../../../app/app_theme.dart';
import '../../sos/shared/models/sos_request.dart';
import '../../sos/shared/models/request_details.dart';
import '../../sos/shared/models/sos_enums.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/services/location_service.dart';

class ProximityRequestTile extends StatefulWidget {
  final SosRequest request;
  final VoidCallback? onAccept;
  final VoidCallback? onStart;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final Position? proPosition;
  final bool hideStatus;

  const ProximityRequestTile({
    super.key,
    required this.request,
    this.onAccept,
    this.onStart,
    this.onDelete,
    this.onTap,
    this.proPosition,
    this.hideStatus = false,
  });

  @override
  State<ProximityRequestTile> createState() => _ProximityRequestTileState();
}

class _ProximityRequestTileState extends State<ProximityRequestTile> {
  String _distanceLabel = "--";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchRoadDistance();
    // Timer pour rafraîchir le texte "il y a X min" chaque minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(ProximityRequestTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.proPosition != oldWidget.proPosition) {
      _fetchRoadDistance();
    }
  }

  Future<void> _fetchRoadDistance() async {
    final patientLoc = widget.request.details.interventionDetails.location;
    if (widget.proPosition == null || patientLoc == null) return;

    final origin = maps.LatLng(widget.proPosition!.latitude, widget.proPosition!.longitude);
    final destination = maps.LatLng(patientLoc.latitude, patientLoc.longitude);
    
    final routeData = await locationService.getRouteData(origin, destination);
    if (mounted && routeData != null) {
      setState(() {
        _distanceLabel = routeData.distanceText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAppointment = widget.request.details.interventionDetails.interventionType == InterventionType.appointment;
    final isTeleconsult = widget.request.details is TeleconsultDetails;
    final appointmentDt = widget.request.details.interventionDetails.appointmentDateTime;
    final now = DateTime.now();
    
    // Un rendez-vous est considéré "en retard" s'il est confirmé et qu'on a dépassé l'heure de 30 min
    final bool isLate = isAppointment && 
                        widget.request.status == RequestStatus.confirmed &&
                        appointmentDt != null && 
                        now.isAfter(appointmentDt.add(const Duration(minutes: 30)));
    
    final bool isTooEarly = isAppointment && appointmentDt != null && 
                            now.isBefore(appointmentDt.subtract(const Duration(minutes: 5)));

    final Color surfaceColor = isDark ? AppTheme.cardDark : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: isLate ? Border.all(color: AppTheme.orangeAccent, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: isLate 
                ? AppTheme.orangeAccent.withOpacity(0.15) 
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isLate 
                        ? AppTheme.orangeAccent.withOpacity(0.1)
                        : (isDark ? Colors.white10 : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isAppointment ? Icons.person_outline : Icons.emergency_outlined,
                    color: isLate ? AppTheme.orangeAccent : (isDark ? Colors.white70 : Colors.black54),
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _getServiceLabel(context, widget.request.details),
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isLate ? Icons.warning_amber_rounded : Icons.access_time, 
                            size: 12, 
                            color: isLate ? AppTheme.orangeAccent : Colors.grey.shade400
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isLate 
                              ? (appointmentDt != null ? "${l10n.appointmentLate} (${DateFormat('HH:mm').format(appointmentDt)})" : l10n.appointmentLate)
                              : (isAppointment && appointmentDt != null 
                                  ? DateFormat('HH:mm').format(appointmentDt)
                                  : _formatTimeAgo(widget.request.createdAt)),
                            style: TextStyle(
                              color: isLate ? AppTheme.orangeAccent : Colors.grey.shade500, 
                              fontSize: 12,
                              fontWeight: isLate ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isTeleconsult)
                      Text(
                        _distanceLabel,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    const SizedBox(height: 8),
                    _buildActionButton(context, l10n, isTooEarly),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, AppLocalizations l10n, bool isTooEarly) {
    final status = widget.request.status;
    
    if (status == RequestStatus.pending) {
      return _GradientButton(
        label: l10n.confirm.toUpperCase(),
        onTap: widget.onAccept,
      );
    } else if (status == RequestStatus.awaiting_payment) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.withOpacity(0.5)),
        ),
        child: const Text(
          "EN ATTENTE PAIEMENT",
          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 9),
        ),
      );
    } else if (status == RequestStatus.confirmed) {
      return _GradientButton(
        label: (widget.request.details is TeleconsultDetails ? l10n.join : l10n.start).toUpperCase(),
        onTap: () {
          if (isTooEarly) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.tooEarlyForAppointment), backgroundColor: AppTheme.orangeAccent)
            );
          } else {
            widget.onStart?.call();
          }
        },
        enabled: !isTooEarly,
      );
    }
    return const SizedBox.shrink();
  }

  String _getServiceLabel(BuildContext context, RequestDetails details) {
    final l10n = AppLocalizations.of(context)!;
    if (details is TeleconsultDetails) return l10n.teleconsultation;
    if (details is DoctorDetails) return l10n.inPersonConsultation;
    if (details is NurseDetails) return l10n.homeCare;
    if (details is AmbulanceDetails) return details.ambulanceType.getLabel(l10n);
    return "SOS";
  }

  String _formatTimeAgo(DateTime? dt) {
    if (dt == null) return "";
    final now = DateTime.now();
    
    if (dt.isAfter(now)) {
      return "À l'instant";
    }

    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return "À l'instant";
    }

    if (diff.inMinutes < 60) {
      return "il y a ${diff.inMinutes} min";
    }

    if (diff.inHours < 24) {
      return "il y a ${diff.inHours} h";
    }

    return DateFormat('dd/MM HH:mm').format(dt);
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  const _GradientButton({required this.label, this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        gradient: enabled ? const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        color: enabled ? null : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}
