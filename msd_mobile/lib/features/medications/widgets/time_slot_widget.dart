import 'package:flutter/material.dart';
import '../../../app/app_theme.dart';

class TimeSlotWidget extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final bool taken;
  final bool isMissed;
  final bool isTooEarly;
  final bool isLate;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const TimeSlotWidget({
    super.key,
    required this.label,
    required this.time,
    required this.icon,
    required this.taken,
    required this.isMissed,
    this.isTooEarly = false,
    this.isLate = false,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Valeurs par défaut (Pending/Futur)
    Color bgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50;
    Color borderColor = isDark ? Colors.white10 : Colors.grey.shade200;
    Color contentColor = isDark ? Colors.white60 : AppTheme.textGrey;
    IconData statusIcon = Icons.access_time_outlined;

    if (taken) {
      bgColor = isDark ? AppTheme.primary.withOpacity(0.15) : const Color(0xFFE8F8F5);
      borderColor = AppTheme.primary.withOpacity(0.3);
      contentColor = AppTheme.primary;
      statusIcon = Icons.check;
    } else if (isMissed) {
      bgColor = AppTheme.redAccent.withOpacity(0.05);
      borderColor = AppTheme.redAccent.withOpacity(0.2);
      contentColor = AppTheme.redAccent;
      statusIcon = Icons.priority_high;
    } else if (isLate) {
      bgColor = Colors.orange.withOpacity(0.05);
      borderColor = Colors.orange.withOpacity(0.3);
      contentColor = isDark ? AppTheme.orangeAccent : Colors.orange.shade700;
      statusIcon = Icons.notification_important_outlined;
    } else if (isTooEarly) {
      contentColor = (isDark ? Colors.white : AppTheme.textGrey).withOpacity(0.4);
      statusIcon = Icons.lock_outline;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 90),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: contentColor),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: contentColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: contentColor,
                  ),
                ),
                const SizedBox(height: 5),
                Icon(
                  statusIcon,
                  size: 14,
                  color: contentColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
