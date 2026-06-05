import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../models/medication.dart';
import '../providers/medication_provider.dart';
import '../widgets/medication_input_fields.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final stockController = TextEditingController();
  final durationController = TextEditingController();
  DateTime selectedStartDate = DateTime.now();
  String? selectedInstruction;
  List<TimeOfDay> customTimes = [];
  
  ReminderType selectedReminderType = ReminderType.notification;
  int leadTimeMinutes = 5;
  int snoozeInterval = 10;

  @override
  void dispose() {
    _pageController.dispose();
    nameController.dispose();
    dosageController.dispose();
    stockController.dispose();
    durationController.dispose();
    super.dispose();
  }

  void _nextPage(AppLocalizations l10n) {
    if (_currentPage == 0) {
      if (nameController.text.trim().isEmpty) {
        _showSnackBar(l10n.medicationNameRequired);
        return;
      }
    }
    
    if (_currentPage == 2 && customTimes.isEmpty) {
      _showSnackBar(l10n.atLeastOneTimeRequired);
      return;
    }

    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.redAccent,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
      ),
    );
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatDateWithCapitalMonth(DateTime date, String locale) {
    String formatted = DateFormat('dd MMMM yyyy', locale).format(date);
    final parts = formatted.split(' ');
    if (parts.length >= 2) {
      parts[1] = parts[1][0].toUpperCase() + parts[1].substring(1);
      return parts.join(' ');
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double effectiveTopMargin = topPadding > 20 ? topPadding : 30.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: effectiveTopMargin + 10),
            _buildAppBar(l10n),
            const SizedBox(height: 12),
            _buildProgressIndicator(),
            
            Flexible(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) => setState(() => _currentPage = page),
                children: [
                  _buildStep(child: _buildStep1(l10n)),
                  _buildStep(child: _buildStep2(l10n)),
                  _buildStep(child: _buildStep3(l10n)),
                  _buildStep(child: _buildStep4(l10n)),
                ],
              ),
            ),
            _buildFooter(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(_currentPage == 0 ? Icons.close : Icons.arrow_back_ios, size: 24, color: isDark ? Colors.white : AppTheme.textDark),
            onPressed: _currentPage == 0 ? () => Navigator.pop(context) : _prevPage,
          ),
          Text(_getTitle(l10n), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          SizedBox(
            width: 48,
            child: Center(
              child: Text("${_currentPage + 1}/4", style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          )
        ],
      ),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    if (_currentPage == 0) return l10n.details;
    if (_currentPage == 1) return l10n.period;
    if (_currentPage == 2) return l10n.times;
    return l10n.reminders;
  }

  Widget _buildStep({required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: child,
    );
  }

  Widget _buildProgressIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: (_currentPage + 1) / 4,
          backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
          minHeight: 6,
        ),
      ),
    );
  }

  Widget _buildStep1(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModalLabel(l10n.medicationName),
        const SizedBox(height: 8),
        ModalTextField(controller: nameController, hint: l10n.medicationNameHint),
        const SizedBox(height: 20),
        ModalLabel(l10n.dosage),
        const SizedBox(height: 8),
        ModalTextField(controller: dosageController, hint: l10n.dosageHint),
        const SizedBox(height: 20),
        ModalLabel(l10n.instruction),
        const SizedBox(height: 8),
        _buildDropdown(l10n),
      ],
    );
  }

  Widget _buildStep2(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModalLabel(l10n.startDate),
        const SizedBox(height: 8),
        _buildDatePicker(),
        const SizedBox(height: 20),
        ModalLabel(l10n.duration),
        const SizedBox(height: 8),
        ModalTextField(controller: durationController, hint: l10n.durationHint, keyboardType: TextInputType.number),
        const SizedBox(height: 20),
        ModalLabel(l10n.initialStock),
        const SizedBox(height: 8),
        ModalTextField(controller: stockController, hint: l10n.stockHint, keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _buildStep3(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ModalLabel(l10n.intakeTimes),
            IconButton(
              onPressed: _addTime,
              icon: const Icon(Icons.add_circle, color: AppTheme.primary, size: 32),
            ),
          ],
        ),
        const SizedBox(height: 8),
        customTimes.isEmpty 
          ? Center(heightFactor: 4, child: Text(l10n.addTimeHint, style: const TextStyle(color: AppTheme.textGrey)))
          : Column(
              children: customTimes.asMap().entries.map((entry) {
                return Card(
                  elevation: 0,
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), 
                    side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.access_time, color: AppTheme.primary),
                    title: Text(entry.value.format(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => setState(() => customTimes.removeAt(entry.key)),
                    ),
                  ),
                );
              }).toList(),
            ),
      ],
    );
  }

  Widget _buildStep4(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModalLabel(l10n.reminderIntensity),
        const SizedBox(height: 16),
        _buildReminderTypeOption(ReminderType.notification, l10n.notificationAlert, l10n.notificationSubtitle, Icons.notifications_none),
        const SizedBox(height: 12),
        _buildReminderTypeOption(ReminderType.alarm, l10n.alarmAlert, l10n.alarmSubtitle, Icons.alarm),
        const SizedBox(height: 24),
        ModalLabel(l10n.notifyBefore(leadTimeMinutes)),
        Slider(
          value: leadTimeMinutes.toDouble(),
          min: 0, max: 30, divisions: 6,
          activeColor: AppTheme.primary,
          onChanged: (v) => setState(() => leadTimeMinutes = v.toInt()),
        ),
        const SizedBox(height: 20),
        ModalLabel(l10n.snoozeInterval),
        const SizedBox(height: 12),
        _buildSnoozeSelector(),
      ],
    );
  }

  Widget _buildSnoozeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final options = [5, 10, 15, 20];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: options.map((min) {
        bool isSelected = snoozeInterval == min;
        return GestureDetector(
          onTap: () => setState(() => snoozeInterval = min),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary : (isDark ? Colors.white10 : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text("$min min", style: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppTheme.textDark), fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderTypeOption(ReminderType type, String title, String sub, IconData icon) {
    bool isSelected = selectedReminderType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => selectedReminderType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.05) : (isDark ? Colors.white.withOpacity(0.02) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.primary : (isDark ? Colors.white10 : Colors.grey.shade200), width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primary : AppTheme.textGrey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? AppTheme.primary : (isDark ? Colors.white : AppTheme.textDark))),
                  Text(sub, style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTime() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) setState(() => customTimes.add(time));
  }

  Widget _buildDatePicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).toString();
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(context: context, initialDate: selectedStartDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
        if (date != null) setState(() => selectedStartDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50, 
          borderRadius: BorderRadius.circular(12), 
          border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDateWithCapitalMonth(selectedStartDate, locale), style: const TextStyle(fontSize: 15)),
            const Icon(Icons.calendar_today, size: 20, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final instructions = {
      l10n.duringMeal: l10n.duringMeal,
      l10n.beforeMeal: l10n.beforeMeal,
      l10n.onEmptyStomach: l10n.onEmptyStomach,
      l10n.afterMeal: l10n.afterMeal,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedInstruction,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          hint: Text(l10n.confirm, style: const TextStyle(fontSize: 15)), // "Choisir" replaced by "Confirm" or similar if needed, or add to arb
          items: instructions.values.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => selectedInstruction = val),
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 60),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _currentPage == 3 ? () => _submit(l10n) : () => _nextPage(l10n),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 0,
          ),
          child: Text(_currentPage == 3 ? l10n.finish : l10n.next, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _submit(AppLocalizations l10n) {
    if (nameController.text.trim().isEmpty) {
      _showSnackBar(l10n.medicationNameRequired);
      return;
    }
    
    if (customTimes.isEmpty) {
      _showSnackBar(l10n.atLeastOneTimeRequired);
      return;
    }

    ref.read(medicationProvider.notifier).addMedication(
      name: nameController.text.trim(),
      dosage: dosageController.text.trim().isEmpty ? "1 comprimé" : dosageController.text.trim(),
      instruction: selectedInstruction ?? l10n.duringMeal,
      times: customTimes,
      initialStock: int.tryParse(stockController.text.trim()) ?? 30,
      lowStockThreshold: 5,
      duration: int.tryParse(durationController.text.trim()) ?? 7,
      startDate: selectedStartDate,
      reminderType: selectedReminderType,
      leadTimeMinutes: leadTimeMinutes,
      snoozeInterval: snoozeInterval,
    );
    Navigator.pop(context);
  }
}
