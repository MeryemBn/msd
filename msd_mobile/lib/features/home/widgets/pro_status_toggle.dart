import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';

class ProStatusToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ProStatusToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), // Plus petit padding
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value ? l10n.onDuty : l10n.offDuty,
            style: TextStyle(
              color: value ? AppTheme.primary : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 11, // Plus petit
            ),
          ),
          const SizedBox(width: 2),
          SizedBox(
            height: 26, // Hauteur réduite
            width: 36,  // Largeur réduite
            child: FittedBox(
              fit: BoxFit.contain,
              child: Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
