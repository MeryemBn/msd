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
import '../../shared/widgets/sos_dropdown_field.dart';
import '../../shared/widgets/sos_payment_step.dart';
import '../../shared/widgets/sos_date_time_picker.dart';
import '../../shared/widgets/sos_professional_step.dart';

class TeleconsultRequestScreen extends ConsumerStatefulWidget {
  const TeleconsultRequestScreen({super.key});

  @override
  ConsumerState<TeleconsultRequestScreen> createState() => _TeleconsultRequestScreenState();
}

class _TeleconsultRequestScreenState extends ConsumerState<TeleconsultRequestScreen> {
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sosProvider.notifier).initNewRequest(
            TeleconsultDetails(
              interventionDetails: InterventionDetails(
                interventionType: InterventionType.appointment,
              ),
              specialty: Specialty.medecineGenerale,
            ),
            200.0,
            SosType.teleconsult,
          );
    });
  }

  int get _totalSteps => 3;

  void _nextStep(AppLocalizations l10n) {
    final state = ref.read(sosProvider);
    if (_currentStep == 1 && state.currentRequest?.details.interventionDetails.appointmentDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chooseDate)));
      return;
    }
    if (_currentStep == 2 && state.selectedProfessional == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.chooseProfessional)));
      return;
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

    if (sosState.currentType != SosType.teleconsult || details is! TeleconsultDetails) {
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

  Widget _buildStepContent(AppLocalizations l10n, TeleconsultDetails details) {
    switch (_currentStep) {
      case 1: return _buildRequestDetailsStep(l10n, details);
      case 2: return const SosProfessionalStep();
      case 3: return const SosPaymentStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildRequestDetailsStep(AppLocalizations l10n, TeleconsultDetails details) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.yourRequest, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.specifyTeleconsult, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 14)),
          const SizedBox(height: 24),
          SosDropdownField<Specialty>(
            label: l10n.specialty,
            hint: l10n.chooseSpecialty,
            value: details.specialty,
            items: Specialty.values.where((s) => s != Specialty.soinsADomicile).toList(),
            itemLabelBuilder: (s) => s.getLabel(l10n),
            prefixIcon: Icons.videocam_outlined,
            onChanged: (val) {
              if (val != null) ref.read(sosProvider.notifier).updateSpecialty(val);
            },
          ),
          const SizedBox(height: 32),
          Text(l10n.interventionType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SosSelectionCard(
            title: l10n.appointment,
            subtitle: l10n.appointmentDesc,
            icon: Icons.calendar_today,
            iconColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
            iconBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
            isSelected: true,
            selectedBorderColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          SosDateTimePicker(
            value: details.interventionDetails.appointmentDateTime,
            onDateTimeChanged: (dt) => ref.read(sosProvider.notifier).updateAppointmentDateTime(dt),
          ),
        ],
      ),
    );
  }
}
