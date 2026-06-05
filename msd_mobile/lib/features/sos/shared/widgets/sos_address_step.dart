import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';

import '../providers/sos_provider.dart';
import '../models/location_details.dart';
import '../../../../shared/widgets/msd_text_field.dart';
import '../../../../core/services/location_service.dart';
import 'sos_map_components.dart';
import 'sos_full_screen_map.dart';

class SosAddressStep extends ConsumerStatefulWidget {
  const SosAddressStep({super.key});

  @override
  ConsumerState<SosAddressStep> createState() => _SosAddressStepState();
}

class _SosAddressStepState extends ConsumerState<SosAddressStep> {
  GoogleMapController? _mapController;
  
  late TextEditingController _addressController;
  late TextEditingController _apptController;
  late TextEditingController _floorController;
  late TextEditingController _codeController;

  bool _isLocating = false;
  LatLng _markerPosition = const LatLng(30.413348526654538, -9.568786360323429);

  @override
  void initState() {
    super.initState();
    final loc = ref.read(sosProvider).currentRequest?.details.interventionDetails.location;
    
    _addressController = TextEditingController(text: loc?.address);
    _apptController = TextEditingController(text: loc?.apartment);
    _floorController = TextEditingController(text: loc?.floor);
    _codeController = TextEditingController(text: loc?.entryCode);

    if (loc != null && loc.latitude != 0) {
      _markerPosition = LatLng(loc.latitude, loc.longitude);
    }

    _setupListeners();
  }

  void _setupListeners() {
    // Débounce léger pour éviter trop d'appels API pendant la saisie
    Timer? debounce;
    void update() {
      if (debounce?.isActive ?? false) debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 500), () {
        _updateProvider();
      });
    }
    
    _addressController.addListener(update);
    _apptController.addListener(update);
    _floorController.addListener(update);
    _codeController.addListener(update);
  }

  @override
  void dispose() {
    for (var c in [_addressController, _apptController, _floorController, _codeController]) {
      c.dispose();
    }
    _mapController?.dispose();
    super.dispose();
  }

  void _updateProvider() {
    ref.read(sosProvider.notifier).updateLocation(
      LocationDetails(
        address: _addressController.text,
        apartment: _apptController.text,
        floor: _floorController.text,
        entryCode: _codeController.text,
        latitude: _markerPosition.latitude,
        longitude: _markerPosition.longitude,
      ),
    );
  }

  void _onLocationSelected(LatLng pos, String addr) {
    setState(() {
      _markerPosition = pos;
      if (addr.isNotEmpty) _addressController.text = addr;
    });
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(pos, 17.0));
    _updateProvider();
  }

  Future<void> _getCurrentLocation(AppLocalizations l10n) async {
    setState(() => _isLocating = true);
    try {
      final pos = await locationService.getCurrentPosition();
      final newLatLng = LatLng(pos.latitude, pos.longitude);
      final addr = await locationService.getAddressFromCoordinates(pos.latitude, pos.longitude);
      _onLocationSelected(newLatLng, addr);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.gpsActivation(e.toString())), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.interventionAddress, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            l10n.specifyLocation, 
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14)
          ),
          const SizedBox(height: 20),
          
          _buildMiniMapPreview(l10n),
          
          const SizedBox(height: 24),
          MsdTextField(
            label: l10n.exactAddress, 
            hint: l10n.addressHint, 
            controller: _addressController, 
            prefixIcon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MsdTextField(
                  label: l10n.apartment, 
                  hint: l10n.apartmentHint, 
                  controller: _apptController, 
                  prefixIcon: Icons.home_outlined
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MsdTextField(
                  label: l10n.floor, 
                  hint: l10n.floorHint, 
                  controller: _floorController, 
                  prefixIcon: Icons.layers_outlined
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MsdTextField(
            label: l10n.entryCode, 
            hint: l10n.entryCodeHint, 
            controller: _codeController, 
            prefixIcon: Icons.vpn_key_outlined
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMapPreview(AppLocalizations l10n) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => FullScreenMapModal(
                initialPosition: _markerPosition,
                onConfirm: _onLocationSelected,
              ),
            ),
          ),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _markerPosition,
                  zoom: 17.0,
                ),
                onMapCreated: (controller) => _mapController = controller,
                markers: {
                  Marker(
                    markerId: const MarkerId('current_location'),
                    position: _markerPosition,
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                tiltGesturesEnabled: false,
                rotateGesturesEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: MapIconButton(
            icon: Icons.fullscreen, 
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => FullScreenMapModal(
                  initialPosition: _markerPosition,
                  onConfirm: _onLocationSelected,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: MapIconButton(
            icon: Icons.my_location, 
            onTap: () => _getCurrentLocation(l10n),
            isPrimary: true, 
            isLoading: _isLocating
          ),
        ),
      ],
    );
  }
}
