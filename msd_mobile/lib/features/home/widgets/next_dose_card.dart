import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../providers/home_provider.dart';

class NextDoseCard extends ConsumerWidget {
  const NextDoseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final homeState = ref.watch(homeProvider).state;
    final nextDose = homeState.nextDoseInfo;
    final isConfirmed = homeState.isLastDoseConfirmed;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (homeState.isLoading && !isConfirmed) {
      return _buildLoadingState(context);
    }

    if (nextDose == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A3835) : const Color(0xFFE8F8F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF234D48) : const Color(0xFFCDEAE5), 
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF33A191),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.done_all_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.allDosesDone,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF4EE2D0) : const Color(0xFF33A191),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.allDosesDoneSubtitle,
                    style: TextStyle(
                      color: isDark ? const Color(0xFFA0D1C8) : const Color(0xFF88BDB4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final confirmedBg = isDark ? const Color(0xFF1A3835) : const Color(0xFFE8F8F6);
    final confirmedBorder = isDark ? const Color(0xFF234D48) : const Color(0xFFCDEAE5);
    final confirmedPrimaryText = isDark ? const Color(0xFF4EE2D0) : const Color(0xFF33A191);

    final pendingGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF3DD6C0), Color(0xFF2DBFAD)],
    );

    final now = DateTime.now();
    final difference = nextDose.scheduledDateTime.difference(now);
    
    final bool isTooEarly = difference.inMinutes > 30;
    final bool isLate = difference.inMinutes < -30; 
    final bool isEnabled = !isTooEarly || isConfirmed;

    Color? bgColor;
    Color contentColor;
    Gradient? gradient;

    if (isConfirmed) {
      bgColor = confirmedBg;
      contentColor = confirmedPrimaryText;
    } else if (isTooEarly) {
      bgColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100;
      contentColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    } else if (isLate) {
      bgColor = isDark ? const Color(0xFF3D2B1F) : const Color(0xFFFFF7EE);
      contentColor = AppTheme.orangeAccent;
    } else {
      contentColor = Colors.white;
      gradient = pendingGradient;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: gradient == null ? bgColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConfirmed 
              ? confirmedBorder 
              : (isTooEarly 
                  ? (isDark ? Colors.white10 : Colors.grey.shade200) 
                  : (isLate ? AppTheme.orangeAccent.withOpacity(0.2) : Colors.transparent)),
          width: 1,
        ),
        boxShadow: [
          if (!isTooEarly || isConfirmed)
            BoxShadow(
              color: (isConfirmed ? confirmedPrimaryText : (isLate ? AppTheme.orangeAccent : const Color(0xFF3DD6C0))).withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isLate && !isConfirmed ? Icons.warning_amber_rounded : (isConfirmed ? Icons.done_all_rounded : Icons.access_time),
                      color: isConfirmed ? contentColor : (isTooEarly ? (isDark ? Colors.grey : Colors.grey) : (isLate ? AppTheme.orangeAccent : Colors.white70)),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isConfirmed ? l10n.doseConfirmed : (isLate ? l10n.doseLate : l10n.nextDose),
                      style: TextStyle(
                        color: isConfirmed ? contentColor : (isTooEarly ? (isDark ? Colors.grey : Colors.grey) : (isLate ? AppTheme.orangeAccent : Colors.white70)),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  nextDose.medicationName,
                  style: TextStyle(
                    color: isConfirmed || isTooEarly || isLate ? contentColor : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${nextDose.formattedTime} • ${nextDose.instruction}',
                  style: TextStyle(
                    color: isConfirmed || isTooEarly || isLate ? contentColor.withOpacity(0.7) : Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isEnabled && !isConfirmed ? () => ref.read(homeProvider).clearNextDose() : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isConfirmed 
                    ? contentColor 
                    : (isTooEarly 
                        ? (isDark ? Colors.white10 : Colors.grey.shade200) 
                        : (isLate ? AppTheme.orangeAccent : Colors.white.withOpacity(0.2))),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isConfirmed ? Icons.check : (isTooEarly ? Icons.lock_outline : Icons.check),
                color: isTooEarly ? (isDark ? Colors.white24 : Colors.grey.shade400) : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
      highlightColor: isDark ? const Color(0xFF3D3D3D) : Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
