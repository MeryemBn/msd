import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../sos/shared/models/sos_type.dart';
import '../../sos/shared/models/sos_enums.dart';

class SosServiceTile extends StatelessWidget {
  final SosType type;
  final VoidCallback onTap;
  final RequestStatus? status;

  const SosServiceTile({
    super.key,
    required this.type,
    required this.onTap,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bool isPending = status == RequestStatus.pending;
    final bool isConfirmed = status == RequestStatus.confirmed;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.fieldBgDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (isPending || isConfirmed) 
                    ? type.iconColor.withOpacity(0.5) 
                    : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
                width: (isPending || isConfirmed) ? 2 : 1,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: type.iconBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    type.icon,
                    size: 28,
                    color: type.iconColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isPending ? 'En attente...' : (isConfirmed ? 'Rejoindre' : type.getLabel(l10n)),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isConfirmed ? type.iconColor : (isDark ? Colors.white : AppTheme.textDark),
                  ),
                ),
              ],
            ),
          ),
          if (isPending)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer_outlined, size: 12, color: Colors.white),
              ),
            ),
          if (isConfirmed)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.videocam, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
