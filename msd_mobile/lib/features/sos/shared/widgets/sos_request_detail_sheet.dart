import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' show min, max;
import '../../../../core/services/location_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../app/app_theme.dart';
import '../../../home/providers/home_provider.dart';
import '../models/sos_request.dart';
import '../models/sos_enums.dart';
import '../models/request_details.dart';
import '../providers/sos_provider.dart';
import 'feedback_dialog.dart';

class SosRequestDetailSheet extends ConsumerWidget {
  final SosRequest request;
  const SosRequestDetailSheet({super.key, required this.request});

  bool _canJoinCall() {
    final appointmentTime = request.details.interventionDetails.appointmentDateTime;
    if (appointmentTime == null) return true;
    final now = DateTime.now();
    final allowedStartTime = appointmentTime.subtract(const Duration(minutes: 5));
    return now.isAfter(allowedStartTime);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final bool isTracking = request.status == RequestStatus.on_the_way;
    final bool isCancelled = request.status == RequestStatus.cancelled;
    final bool isConfirmed = request.status == RequestStatus.confirmed;
    final bool isInProgress = request.status == RequestStatus.in_progress;
    final bool isCompleted = request.status == RequestStatus.completed;
    final bool isAwaitingPayment = request.status == RequestStatus.awaiting_payment;
    final bool isTeleconsult = request.details is TeleconsultDetails;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, 
            height: 4, 
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey.shade300, 
              borderRadius: BorderRadius.circular(2)
            )
          ),
          const SizedBox(height: 24),

          _buildHeader(context, isTracking, l10n),
          const SizedBox(height: 24),

          if (isTeleconsult && (isConfirmed || isInProgress)) ...[
            _buildTeleconsultJoinSection(context, ref, l10n),
            const SizedBox(height: 24),
          ],

          if (isTracking) ...[
            _buildTrackingSection(context, l10n),
          ] else ...[
            _buildStatusHeader(l10n),
            const SizedBox(height: 20),
            _buildInfoList(context, isCancelled, l10n),
          ],

          if (isAwaitingPayment)
            _buildPayButton(context, l10n),

          if (isCompleted && !request.isRated)
            _buildFeedbackButton(context, l10n),

          if (!isCancelled && 
              !isCompleted && 
              request.status != RequestStatus.on_the_way && 
              request.status != RequestStatus.in_progress)
             _buildCancelButton(context, ref, l10n, isOutlined: (isTeleconsult && isConfirmed) || isAwaitingPayment),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          // Action statique pour le moment
        },
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text("PROCÉDER AU PAIEMENT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildFeedbackButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) => FeedbackDialog(request: request),
          );
        },
        icon: const Icon(Icons.star_rounded, color: Colors.white),
        label: const Text("NOTER L'INTERVENTION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber.shade700,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildTrackingSection(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.near_me, color: Color(0xFF2DBFAD), size: 18),
                const SizedBox(width: 8),
                Text(l10n.realTimeTracking, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            TextButton.icon(
              onPressed: () => context.push('/sos/tracking', extra: request),
              icon: const Icon(Icons.fullscreen, size: 18, color: Color(0xFF2DBFAD)),
              label: const Text("Agrandir", style: TextStyle(color: Color(0xFF2DBFAD), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _TrackingMapPreview(request: request),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 24, 
            backgroundColor: const Color(0xFF2DBFAD).withOpacity(0.1), 
            child: const Icon(Icons.person, color: Color(0xFF2DBFAD))
          ),
          title: Text(
            request.professionalFullName.isNotEmpty ? request.professionalFullName : "Professionnel", 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
          ),
          subtitle: Text(l10n.identityVerified, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          trailing: Container(
            decoration: BoxDecoration(color: const Color(0xFF2DBFAD).withOpacity(0.1), shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.phone, color: Color(0xFF2DBFAD)), 
              onPressed: () async {
                final phone = request.professionalPhoneNumber;
                if (phone != null && phone.isNotEmpty) {
                  await launchUrl(Uri.parse('tel:$phone'));
                }
              }
            ),
          ),
        ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isTracking, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isTracking 
                ? const Color(0xFF2DBFAD).withOpacity(0.1) 
                : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(_getIcon(), color: isTracking ? const Color(0xFF2DBFAD) : (isDark ? Colors.white70 : Colors.black87), size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getTitle(l10n), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
              Text(_getSubtitle(l10n), style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade500, fontSize: 14)),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white24 : Colors.grey.shade400),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildStatusHeader(AppLocalizations l10n) {
    final color = _getStatusColor(request.status);
    return Row(
      children: [
        Icon(_getStatusIcon(request.status), color: color, size: 20),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(request.status.getLabel(l10n).toUpperCase(), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        if (request.isRated && request.rating != null) ...[
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return Icon(
                index < request.rating! ? Icons.star_rounded : Icons.star_outline_rounded,
                color: Colors.amber,
                size: 20,
              );
            }),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending: return Colors.orange;
      case RequestStatus.awaiting_payment: return Colors.amber.shade700;
      case RequestStatus.confirmed: return Colors.blue;
      case RequestStatus.on_the_way: return Colors.indigo;
      case RequestStatus.in_progress: return Colors.teal;
      case RequestStatus.completed: return Colors.green;
      case RequestStatus.cancelled:
      case RequestStatus.rejected: return Colors.red;
    }
  }

  IconData _getStatusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending: return Icons.hourglass_top_rounded;
      case RequestStatus.awaiting_payment: return Icons.payments_outlined;
      case RequestStatus.confirmed: return Icons.check_circle_rounded;
      case RequestStatus.on_the_way: return Icons.near_me_rounded;
      case RequestStatus.in_progress: return Icons.videocam_rounded;
      case RequestStatus.completed: return Icons.verified_rounded;
      case RequestStatus.cancelled:
      case RequestStatus.rejected: return Icons.cancel_rounded;
    }
  }

  Widget _buildInfoList(BuildContext context, bool isCancelled, AppLocalizations l10n) {
    final dt = request.details.interventionDetails.appointmentDateTime ?? request.createdAt ?? DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;
    final formattedDt = DateFormat('dd MMM yyyy à HH:mm', locale).format(dt);
    final address = request.details.interventionDetails.location?.address;
    String proName = request.professionalFullName.isNotEmpty ? request.professionalFullName : l10n.waiting;
    final price = request.price;
    final typeLabel = request.details.interventionDetails.interventionType?.getLabel(l10n) ?? "SOS";

    return Column(
      children: [
        _buildInfoRow(context, Icons.info_outline, l10n.interventionType, typeLabel),
        _buildInfoRow(context, Icons.calendar_today, l10n.dateAndTime, formattedDt),
        if (address != null && address.isNotEmpty)
          _buildInfoRow(context, Icons.location_on_outlined, l10n.addressLabel, address),
        _buildInfoRow(context, Icons.medical_information_outlined, l10n.professionalLabel, proName),
        _buildInfoRow(context, Icons.payments_outlined, l10n.estimatedAmount, '${price.toStringAsFixed(0)} MAD'),
        if (isCancelled) _buildInfoRow(context, Icons.info_outline, l10n.noteLabel, l10n.cancelledByUser),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50, 
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(icon, size: 20, color: isDark ? Colors.white38 : Colors.grey.shade400),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white30 : Colors.grey.shade400, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context, WidgetRef ref, AppLocalizations l10n, {bool isOutlined = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8),
      child: ElevatedButton(
        onPressed: () => _showCancelConfirmation(context, ref, l10n),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : const Color(0xFFFFEBEB).withOpacity(0.1),
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), 
            side: isOutlined ? const BorderSide(color: Color(0xFFFFEBEB), width: 0.5) : BorderSide.none
          ),
        ),
        child: Text(l10n.cancelRequest, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  void _showCancelConfirmation(BuildContext sheetContext, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.cancelRequestConfirmTitle),
        content: Text(l10n.cancelRequestConfirmMessage),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.keepRequest, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref.read(sosProvider.notifier).cancelRequest(request.id!);
                if (sheetContext.mounted) {
                   Navigator.pop(sheetContext);
                   ScaffoldMessenger.of(sheetContext).showSnackBar(
                     SnackBar(content: Text(l10n.requestCancelledSuccess), backgroundColor: Colors.green),
                   );
                }
              } catch (e) {
                if (sheetContext.mounted) {
                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                    SnackBar(content: Text(l10n.errorPrefix(e.toString())), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text(l10n.yesCancel, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    final details = request.details;
    if (details is DoctorDetails) return Icons.medical_services_outlined;
    if (details is NurseDetails) return Icons.health_and_safety_outlined;
    if (details is TeleconsultDetails) return Icons.videocam_outlined;
    if (details is AmbulanceDetails) return Icons.medical_services;
    return Icons.medical_services_outlined;
  }

  String _getTitle(AppLocalizations l10n) {
    final details = request.details;
    if (details is DoctorDetails) return l10n.doctor;
    if (details is NurseDetails) return l10n.nurse;
    if (details is TeleconsultDetails) return l10n.teleconsultation;
    if (details is AmbulanceDetails) return l10n.ambulance;
    return 'SOS';
  }

  String _getSubtitle(AppLocalizations l10n) {
    final details = request.details;
    if (details is DoctorDetails) return details.specialty.getLabel(l10n);
    if (details is NurseDetails) return l10n.homeCare;
    if (details is TeleconsultDetails) return l10n.videoConsultation(details.specialty.getLabel(l10n));
    if (details is AmbulanceDetails) return details.ambulanceType.getLabel(l10n);
    return l10n.healthServices;
  }

  Widget _buildTeleconsultJoinSection(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final canJoin = _canJoinCall();
    final appointmentDt = request.details.interventionDetails.appointmentDateTime;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.videocam, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  canJoin ? "Votre téléconsultation est prête" : "Téléconsultation prévue bientôt",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canJoin ? () => _joinCall(context, ref) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade500,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                canJoin 
                  ? "REJOINDRE L'APPEL" 
                  : (appointmentDt != null ? "DISPONIBLE À ${DateFormat('HH:mm').format(appointmentDt.subtract(const Duration(minutes: 5)))}" : "REJOINDRE L'APPEL"), 
                style: const TextStyle(fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinCall(BuildContext context, WidgetRef ref) async {
    final status = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (status[Permission.camera]!.isGranted &&
        status[Permission.microphone]!.isGranted) {
      final homeState = ref.read(homeProvider).state;
      if (context.mounted) {
        context.push('/teleconsult-call', extra: {
          'roomName': request.roomName ?? 'MSD_Teleconsult_${request.id}',
          'jwt': request.jitsiToken,
          'displayName': homeState.patientName,
          'email': homeState.userProfile?.email,
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
}

class _TrackingMapPreview extends StatefulWidget {
  final SosRequest request;
  const _TrackingMapPreview({required this.request});

  @override
  State<_TrackingMapPreview> createState() => _TrackingMapPreviewState();
}

class _TrackingMapPreviewState extends State<_TrackingMapPreview> {
  GoogleMapController? _mapController;
  StreamSubscription? _subscription;
  LatLng? _proPos;
  String? _etaText;
  Set<Polyline> _polylines = {};
  bool _isFirstLoad = true;
  final String _dbUrl = "https://msd-mobile-21fb4-default-rtdb.europe-west1.firebasedatabase.app/";

  @override
  void initState() {
    super.initState();
    _setupTracking();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _setupTracking() {
    _subscription = FirebaseDatabase.instanceFor(
      app: Firebase.app(), 
      databaseURL: _dbUrl
    ).ref('tracking/${widget.request.id}').onValue.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final newPos = LatLng((data['lat'] as num).toDouble(), (data['lng'] as num).toDouble());
          
          if (mounted) {
            setState(() { _proPos = newPos; });
            _updateData(newPos);
          }
        } catch (e) { debugPrint("Error tracking preview: $e"); }
      }
    });
  }

  Future<void> _updateData(LatLng proPos) async {
    final loc = widget.request.details.interventionDetails.location;
    if (loc == null) return;
    final targetPos = LatLng(loc.latitude, loc.longitude);

    final routeData = await locationService.getRouteData(proPos, targetPos);

    if (mounted && routeData != null) {
      setState(() {
        _etaText = routeData.durationText;
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: routeData.points,
            color: const Color(0xFF2DBFAD),
            width: 4,
          ),
        };
      });
      if (!_isFirstLoad) {
        _fitBounds(targetPos, proPos);
      }
    }
  }

  void _fitBounds(LatLng p1, LatLng p2) {
    if (_mapController == null) return;
    final bounds = LatLngBounds(
      southwest: LatLng(min(p1.latitude, p2.latitude), min(p1.longitude, p2.longitude)),
      northeast: LatLng(max(p1.latitude, p2.latitude), max(p1.longitude, p2.longitude)),
    );
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 30.0));
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.request.details.interventionDetails.location;
    final targetPos = loc != null ? LatLng(loc.latitude, loc.longitude) : const LatLng(33.5731, -7.5898);

    return Container(
      height: 160, 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.grey.shade100
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: targetPos, zoom: 15),
              onMapCreated: (c) {
                _mapController = c;
                if (_proPos != null) {
                  _fitBounds(targetPos, _proPos!);
                  _isFirstLoad = false;
                }
              },
              markers: {
                if (_proPos != null)
                  Marker(
                    markerId: const MarkerId('pro'),
                    position: _proPos!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  ),
                Marker(
                  markerId: const MarkerId('patient'),
                  position: targetPos,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
              },
              polylines: _polylines,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              rotateGesturesEnabled: false,
              mapToolbarEnabled: false,
            ),
            
            if (_etaText != null)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_filled, size: 14, color: Color(0xFF2DBFAD)),
                      const SizedBox(width: 4),
                      Text(
                        _etaText!,
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

            if (_proPos == null)
              const Center(child: CircularProgressIndicator(color: Color(0xFF2DBFAD))),
          ],
        ),
      ),
    );
  }
}
