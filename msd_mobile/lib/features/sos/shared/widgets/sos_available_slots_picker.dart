import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/app_localizations.dart';
import '../services/sos_service.dart';

class SosAvailableSlotsPicker extends StatefulWidget {
  final int professionalId;
  final DateTime? selectedDateTime;
  final Function(DateTime) onSlotSelected;

  const SosAvailableSlotsPicker({
    super.key,
    required this.professionalId,
    required this.selectedDateTime,
    required this.onSlotSelected,
  });

  @override
  State<SosAvailableSlotsPicker> createState() => _SosAvailableSlotsPickerState();
}

class _SosAvailableSlotsPickerState extends State<SosAvailableSlotsPicker> {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _availableSlots = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.selectedDateTime != null) {
      _selectedDate = DateTime(
        widget.selectedDateTime!.year,
        widget.selectedDateTime!.month,
        widget.selectedDateTime!.day,
      );
    }
    _fetchAvailableSlots();
  }

  Future<void> _fetchAvailableSlots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final slots = await sosService.getAvailableSlots(
        professionalId: widget.professionalId,
        date: _selectedDate,
      );
      setState(() {
        _availableSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
        _availableSlots = [];
      });
    }
  }

  Future<void> _selectDate(BuildContext context, AppLocalizations l10n) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark
              ? const ColorScheme.dark(
                  primary: Color(0xFF2DBFAD),
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E1E1E),
                )
              : const ColorScheme.light(
                  primary: Color(0xFF2DBFAD),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchAvailableSlots();
    }
  }

  List<List<DateTime>> _groupSlotsByPeriod() {
    final morning = <DateTime>[];
    final afternoon = <DateTime>[];
    final evening = <DateTime>[];

    for (var slot in _availableSlots) {
      if (slot.hour < 12) {
        morning.add(slot);
      } else if (slot.hour < 17) {
        afternoon.add(slot);
      } else {
        evening.add(slot);
      }
    }

    return [morning, afternoon, evening];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    final periods = _groupSlotsByPeriod();
    final periodLabels = [l10n.morning ?? 'Matin', l10n.afternoon ?? 'Après-midi', l10n.evening ?? 'Soir'];
    final periodIcons = [Icons.wb_sunny, Icons.wb_cloudy, Icons.nights_stay];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.appointmentDate,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Date Selector
        InkWell(
          onTap: () => _selectDate(context, l10n),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month, size: 20, color: Color(0xFF2DBFAD)),
                const SizedBox(width: 12),
                Text(
                  DateFormat.yMMMMd(locale).format(_selectedDate),
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Color(0xFF2DBFAD)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          l10n.availableTimeSlots ?? 'Créneaux disponibles',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Loading State
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: Color(0xFF2DBFAD)),
            ),
          ),

        // Error State
        if (_errorMessage != null && !_isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),

        // Available Slots by Period
        if (!_isLoading && _errorMessage == null && _availableSlots.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 48, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noAvailableSlots ?? 'Aucun créneau disponible',
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.tryAnotherDate ?? 'Essayez une autre date',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

        if (!_isLoading && _errorMessage == null && _availableSlots.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                final periodSlots = periods[index];
                if (periodSlots.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Icon(periodIcons[index], size: 20, color: const Color(0xFF2DBFAD)),
                          const SizedBox(width: 8),
                          Text(
                            periodLabels[index],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF2DBFAD),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: periodSlots.map((slot) {
                        final isSelected = widget.selectedDateTime != null &&
                            slot.year == widget.selectedDateTime!.year &&
                            slot.month == widget.selectedDateTime!.month &&
                            slot.day == widget.selectedDateTime!.day &&
                            slot.hour == widget.selectedDateTime!.hour &&
                            slot.minute == widget.selectedDateTime!.minute;

                        return InkWell(
                          onTap: () => widget.onSlotSelected(slot),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2DBFAD)
                                  : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FA)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF2DBFAD)
                                    : (isDark ? Colors.white10 : Colors.grey.shade200),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              DateFormat('HH:mm').format(slot),
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black87),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
