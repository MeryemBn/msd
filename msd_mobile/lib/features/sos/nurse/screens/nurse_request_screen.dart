import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/step_progress_bar.dart';
import '../../../../shared/widgets/msd_button.dart';
import '../../shared/models/sos_enums.dart';
import '../../shared/models/sos_type.dart';
import '../../shared/models/request_details.dart';
import '../../shared/models/intervention_details.dart';
import '../../shared/providers/sos_provider.dart';
import '../../shared/widgets/sos_selection_card.dart';
import '../../shared/widgets/sos_address_step.dart';
import '../../shared/widgets/sos_payment_step.dart';
import '../../shared/widgets/sos_professional_step.dart';
import '../../shared/widgets/sos_available_slots_picker.dart';

class NurseRequestScreen extends ConsumerStatefulWidget {
  const NurseRequestScreen({super.key});

  @override
  ConsumerState<NurseRequestScreen> createState() => _NurseRequestScreenState();
}

class _NurseRequestScreenState extends ConsumerState<NurseRequestScreen> {
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sosProvider.notifier).initNewRequest(
            NurseDetails(
              interventionDetails: InterventionDetails(
                interventionType: null,
              ),
            ),
            250.0,
            SosType.nurse,
          );
    });
  }

  int get _totalSteps {
    final state = ref.read(sosProvider);
    final interventionType = state.currentRequest?.details.interventionDetails.interventionType;
    return interventionType == InterventionType.appointment ? 5 : 3;
  }

  void _nextStep(AppLocalizations l10n) {
    final state = ref.read(sosProvider);
    final interventionType = state.currentRequest?.details.interventionDetails.interventionType;

    if (_currentStep == 1 && interventionType == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chooseInterventionType)));
      return;
    }
    
    if (interventionType == InterventionType.appointment) {
      if (_currentStep == 3 && state.selectedProfessional == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chooseProfessional)));
        return;
      }
      if (_currentStep == 4 && state.currentRequest?.details.interventionDetails.appointmentDateTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chooseTimeSlot)));
        return;
      }
    }
    
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _submitRequest(l10n);
    }
  }

  void _prevStep() => _currentStep > 1 ? setState(() => _currentStep--) : Navigator.pop(context);

  void _submitRequest(AppLocalizations l10n) {
    ref.read(sosProvider.notifier).submitRequest().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.requestSent)));
      Navigator.pop(context);
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sosState = ref.watch(sosProvider);
    final details = sosState.currentRequest?.details;

    if (sosState.currentType != SosType.nurse || details is! NurseDetails) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StepProgressBar(currentStep: _currentStep, totalSteps: _totalSteps, onBack: _prevStep),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildStepContent(l10n, details),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: MsdButton(
                text: _currentStep == _totalSteps ? l10n.confirmRequest : l10n.continueText,
                onPressed: () => _nextStep(l10n),
                isLoading: sosState.isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(AppLocalizations l10n, NurseDetails details) {
    final interventionType = details.interventionDetails.interventionType;

    if (interventionType == InterventionType.appointment) {
      switch (_currentStep) {
        case 1: return _buildRequestDetailsStep(l10n, details);
        case 2: return const SosAddressStep();
        case 3: return const SosProfessionalStep();
        case 4: return _buildAvailableSlotsStep();
        case 5: return const SosPaymentStep();
        default: return const SizedBox.shrink();
      }
    } else {
      switch (_currentStep) {
        case 1: return _buildRequestDetailsStep(l10n, details);
        case 2: return const SosAddressStep();
        case 3: return const SosPaymentStep();
        default: return const SizedBox.shrink();
      }
    }
  }

  Widget _buildRequestDetailsStep(AppLocalizations l10n, NurseDetails details) {
    final interventionType = details.interventionDetails.interventionType;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.yourRequest, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.specifySpecialtyAndIntervention, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FA), 
              borderRadius: BorderRadius.circular(12)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.specialty, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(l10n.homeCare, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text(l10n.interventionType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          SosSelectionCard(
            title: l10n.sosUrgency,
            subtitle: l10n.sosUrgencyDesc,
            icon: Icons.flash_on,
            iconColor: const Color(0xFFFF5252),
            iconBackgroundColor: const Color(0xFFFFEBEE),
            isSelected: interventionType == InterventionType.sos_urgency,
            selectedBorderColor: const Color(0xFFFF5252),
            onTap: () => ref.read(sosProvider.notifier).updateInterventionType(InterventionType.sos_urgency),
          ),
          SosSelectionCard(
            title: l10n.appointment,
            subtitle: l10n.appointmentDesc,
            icon: Icons.calendar_today,
            iconColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
            iconBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
            isSelected: interventionType == InterventionType.appointment,
            selectedBorderColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
            onTap: () => ref.read(sosProvider.notifier).updateInterventionType(InterventionType.appointment),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableSlotsStep() {
    final sosState = ref.watch(sosProvider);
    final selectedProfessional = sosState.selectedProfessional;
    final details = sosState.currentRequest?.details as NurseDetails?;

    if (selectedProfessional == null || details == null) {
      return const Center(child: Text('Erreur: Aucun professionnel sélectionné'));
    }

    return SosAvailableSlotsPicker(
      professionalId: selectedProfessional.id!,
      selectedDateTime: details.interventionDetails.appointmentDateTime,
      onSlotSelected: (dateTime) {
        ref.read(sosProvider.notifier).updateAppointmentDateTime(dateTime);
      },
    );
  }
}
