import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class LegendWidget extends StatelessWidget {
  const LegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Theme.of(context).cardTheme.color,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _legendItem(context, Colors.green.shade400, l10n.legendTaken),
          _legendItem(context, const Color(0xFFE8A048), l10n.legendPartial),
          _legendItem(context, const Color(0xFFFF5252), l10n.legendMissed),
          _legendItem(context, Colors.grey.shade300, l10n.legendFuture),
        ],
      ),
    );
  }

  Widget _legendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
