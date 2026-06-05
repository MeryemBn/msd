import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../providers/notification_provider.dart';

class HomeHeader extends ConsumerWidget {
  final String patientName;

  const HomeHeader({
    super.key,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notificationState = ref.watch(notificationProvider);
    final unreadCount = notificationState.unreadCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.hello,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textGrey),
                ),
                const Text('👋', style: TextStyle(fontSize: 14)),
              ],
            ),
            Text(
              patientName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.textDark,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.push('/notifications'),
          child: Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.fieldBgDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_outlined, 
                  size: 22,
                  color: isDark ? Colors.white70 : AppTheme.textDark,
                ),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppTheme.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF121212) : Colors.white,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
