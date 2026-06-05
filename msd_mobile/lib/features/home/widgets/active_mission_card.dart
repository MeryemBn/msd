import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import '../../sos/shared/models/sos_enums.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/services/location_service.dart';
import '../../../app/app_theme.dart';

class ActiveMissionCard extends StatefulWidget {
  final String requestId;
  final String patientName;
  final String patientPhoneNumber;
  final String serviceDetails;
  final String address;
  final String price;
  final RequestStatus status;
  final VoidCallback onAction;
  final VoidCallback? onTap;
  final VoidCallback? onJoinCall;
  final VoidCallback? onItinerary;
  final double? patientLat;
  final double? patientLng;
  final Position? proPosition;
  final bool isTeleconsult;
  final String? meetingUrl;
  final DateTime? appointmentDateTime;

  const ActiveMissionCard({
    super.key,
    required this.requestId,
    required this.patientName,
    required this.patientPhoneNumber,
    required this.serviceDetails,
    required this.address,
    required this.price,
    required this.status,
    required this.onAction,
    this.onTap,
    this.onJoinCall,
    this.onItinerary,
    this.patientLat,
    this.patientLng,
    this.proPosition,
    this.isTeleconsult = false,
    this.meetingUrl,
    this.appointmentDateTime,
  });

  @override
  State<ActiveMissionCard> createState() => _ActiveMissionCardState();
}

class _ActiveMissionCardState extends State<ActiveMissionCard> {
  Timer? _refreshTimer;
  String _distanceLabel = "--";
  String _distanceUnit = "";

  @override
  void initState() {
    super.initState();
    _fetchRoadDistance();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _fetchRoadDistance();
    });
  }

  @override
  void didUpdateWidget(ActiveMissionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.proPosition != oldWidget.proPosition) {
      _fetchRoadDistance();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchRoadDistance() async {
    if (widget.isTeleconsult || widget.proPosition == null || widget.patientLat == null || widget.patientLng == null) {
      if (mounted) setState(() { _distanceLabel = "--"; _distanceUnit = ""; });
      return;
    }

    final origin = maps.LatLng(widget.proPosition!.latitude, widget.proPosition!.longitude);
    final destination = maps.LatLng(widget.patientLat!, widget.patientLng!);
    
    final routeData = await locationService.getRouteData(origin, destination);
    
    if (mounted && routeData != null) {
      setState(() {
        final parts = routeData.distanceText.split(' ');
        if (parts.length >= 2) {
          _distanceLabel = parts[0];
          _distanceUnit = parts[1].toUpperCase();
        } else {
          _distanceLabel = routeData.distanceText;
          _distanceUnit = "";
        }
      });
    }
  }

  bool _canJoinMeeting() {
    if (widget.appointmentDateTime == null) return true;
    final now = DateTime.now();
    final allowedStartTime = widget.appointmentDateTime!.subtract(const Duration(minutes: 15));
    return now.isAfter(allowedStartTime);
  }

  Future<void> _makePhoneCall() async {
    if (widget.patientPhoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: widget.patientPhoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint("Erreur appel: $e");
    }
  }

  Future<void> _handleItinerary() async {
    if (widget.onItinerary != null) {
      widget.onItinerary!();
    } else {
      if (widget.patientLat == null || widget.patientLng == null) return;
      await locationService.launchDirections(widget.patientLat!, widget.patientLng!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final bool isActionDone = widget.isTeleconsult 
        ? widget.status == RequestStatus.in_progress 
        : widget.status == RequestStatus.on_the_way;

    final String displayId = widget.requestId.length >= 8
        ? widget.requestId.substring(0, 8).toUpperCase()
        : widget.requestId.toUpperCase();

    final bool canJoin = _canJoinMeeting();
    final List<Color> cardGradient = [AppTheme.primary, AppTheme.primaryDark];

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: cardGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isTeleconsult ? l10n.visioConference.toUpperCase() : "MISSION: $displayId",
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                  child: Text(widget.price, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.patientName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1),
                      Text(widget.serviceDetails, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(widget.isTeleconsult ? Icons.videocam : Icons.location_on, color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.isTeleconsult ? l10n.distConsultation : widget.address,
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!widget.isTeleconsult) ...[
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      Text(_distanceLabel, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(_distanceUnit, style: const TextStyle(color: Colors.white70, fontSize: 9)),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (!widget.isTeleconsult) ...[
                  Expanded(child: _ActionBtn(icon: Icons.directions, label: l10n.itinerary, onTap: _handleItinerary)),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: _ActionBtn(
                    icon: widget.isTeleconsult ? Icons.video_call : Icons.call,
                    label: widget.isTeleconsult
                        ? (canJoin ? l10n.join : "À ${DateFormat('HH:mm').format(widget.appointmentDateTime!)}")
                        : l10n.phone,
                    enabled: widget.isTeleconsult ? canJoin : true,
                    onTap: widget.isTeleconsult ? (widget.onJoinCall ?? () {}) : _makePhoneCall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 0,
                  disabledBackgroundColor: Colors.white.withOpacity(0.5),
                ),
                child: Text(
                  isActionDone ? l10n.done.toUpperCase() : (widget.isTeleconsult ? l10n.join.toUpperCase() : l10n.start.toUpperCase()),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  const _ActionBtn({required this.icon, required this.label, required this.onTap, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: enabled ? Colors.white12 : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: enabled ? Colors.white : Colors.white38, size: 14),
              const SizedBox(width: 4),
              Flexible(child: Text(label, style: TextStyle(color: enabled ? Colors.white : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }
}
