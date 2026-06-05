import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';

class PharmacyBanner extends StatelessWidget {
  final VoidCallback onTap;

  const PharmacyBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.fieldBgDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.grey.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.orangeAccent.withOpacity(0.15) : const Color(0xFFFFF8EE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFFE8A048),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.onDutyPharmacy,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.findNearest,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 18, color: AppTheme.textGrey),
          ],
        ),
      ),
    );
  }
}
