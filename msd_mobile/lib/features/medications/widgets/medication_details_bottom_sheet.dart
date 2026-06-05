import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/medication.dart';
import '../providers/medication_provider.dart';

class MedicationDetailsBottomSheet extends ConsumerStatefulWidget {
  final Medication medication;

  const MedicationDetailsBottomSheet({super.key, required this.medication});

  @override
  ConsumerState<MedicationDetailsBottomSheet> createState() => _MedicationDetailsBottomSheetState();
}

class _MedicationDetailsBottomSheetState extends ConsumerState<MedicationDetailsBottomSheet> {
  final TextEditingController _refillController = TextEditingController();
  int _addedQuantity = 0;

  @override
  void initState() {
    super.initState();
    _refillController.addListener(() {
      setState(() {
        _addedQuantity = int.tryParse(_refillController.text) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _refillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final med = widget.medication;
    final endDate = med.startDate.add(Duration(days: med.durationInDays - 1));
    final bool isCritical = med.currentStock <= 2;
    final bool isLow = med.currentStock <= med.lowStockThreshold;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300, 
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.medicationName, 
                          style: TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: isDark ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (isLow)
                           Container(
                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             decoration: BoxDecoration(
                               color: (isCritical ? Colors.red : Colors.orange).withOpacity(0.1),
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Text(
                               isCritical ? l10n.criticalStock.toUpperCase() : l10n.lowStock.toUpperCase(),
                               style: TextStyle(color: isCritical ? Colors.red : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                             ),
                           ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.medication, color: AppTheme.primary, size: 30),
                  ),
                ],
              ),
              const Divider(height: 40),
              
              _buildInfoRow(Icons.calendar_today, l10n.startOfTreatment, DateFormat.yMMMMd(locale).format(med.startDate)),
              _buildInfoRow(Icons.event, l10n.endOfTreatment, DateFormat.yMMMMd(locale).format(endDate)),
              _buildInfoRow(Icons.access_time, l10n.frequency, l10n.takesPerDay(med.intakeTimes.length)),
              
              const SizedBox(height: 12),
              Text(l10n.refillStock, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.03) : AppTheme.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.currentStock, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        Text(
                          "${med.currentStock}", 
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: isDark ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.quantityToAdd, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: _refillController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 20, 
                              color: isDark ? const Color(0xFF4EE2D0) : AppTheme.primary,
                            ),
                            decoration: InputDecoration(
                              hintText: "+ 0",
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              filled: true,
                              fillColor: isDark ? Colors.white10 : Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_addedQuantity > 0) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.newStock(med.currentStock + _addedQuantity),
                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addedQuantity > 0 ? () {
                    ref.read(medicationProvider.notifier).refillStock(med.id, _addedQuantity);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.stockRefilledSuccess(med.medicationName)),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    disabledBackgroundColor: isDark ? Colors.white10 : Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(l10n.confirmRefill, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textGrey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
              Text(
                value, 
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.w600, 
                  color: isDark ? Colors.white70 : AppTheme.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
