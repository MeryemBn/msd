import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';

class ClearNotificationsDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ClearNotificationsDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        l10n.confirmClearHistory,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
      ),
      content: Text(
        l10n.clearHistoryMessage,
        style: const TextStyle(color: AppTheme.textGrey),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w600),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.redAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(l10n.clearAll, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
