import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../providers/notification_provider.dart';
import '../models/notification_item.dart';
import '../widgets/clear_notifications_dialog.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(notificationProvider);
    final notifier = ref.read(notificationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.notifications,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (state.notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.redAccent),
              onPressed: () => _showClearDialog(context, notifier, l10n),
            ),
        ],
      ),
      body: state.notifications.isEmpty
          ? _buildEmptyState(l10n)
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = state.notifications[index];
          return _NotificationTile(notification: notification);
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noNotifications,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noNotificationsSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, NotificationNotifier notifier, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => ClearNotificationsDialog(
        onConfirm: () => notifier.clearHistory(),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (notification.type) {
      case 'stock':
      case 'sos_rejected':
      case 'sos_cancelled':
        iconData = notification.type == 'stock' ? Icons.inventory_2_outlined : Icons.cancel_outlined;
        iconColor = AppTheme.redAccent;
        bgColor = isDark ? const Color(0xFF3D1F1F) : const Color(0xFFFFF2F2);
        break;
      case 'sos_accepted':
        iconData = Icons.check_circle_outline_rounded;
        iconColor = Colors.green;
        bgColor = isDark ? const Color(0xFF1B3D1F) : const Color(0xFFF2FFF2);
        break;
      case 'sos':
      case 'appointment':
      case 'sos_status':
      case 'admin_new_sos':
        iconData = (notification.type == 'sos' || notification.type == 'sos_status' || notification.type == 'admin_new_sos') 
            ? Icons.emergency_outlined 
            : Icons.calendar_today_rounded;
        iconColor = AppTheme.orangeAccent;
        bgColor = isDark ? const Color(0xFF3D2E1F) : const Color(0xFFFFF8F2);
        break;
      case 'review':
        iconData = Icons.star_rounded;
        iconColor = Colors.amber;
        bgColor = isDark ? const Color(0xFF3D351F) : const Color(0xFFFFFBE6);
        break;
      case 'admin_new_pro':
        iconData = Icons.person_add_alt_1_rounded;
        iconColor = AppTheme.primary;
        bgColor = isDark ? const Color(0xFF1A3835) : const Color(0xFFE8F8F6);
        break;
      case 'admin_new_patient':
        iconData = Icons.person_outline_rounded;
        iconColor = Colors.blue;
        bgColor = isDark ? const Color(0xFF1F2E3D) : const Color(0xFFF2F8FF);
        break;
      case 'medication':
      default:
        iconData = Icons.medication_outlined;
        iconColor = AppTheme.primary;
        bgColor = isDark ? const Color(0xFF1A3835) : const Color(0xFFE8F8F6);
        break;
    }

    // Titre personnalisé si c'est un médicament
    String displayTitle = notification.title;
    if (notification.type == 'medication' && notification.medicationName != null) {
      displayTitle = notification.medicationName!;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: (notification.type == 'medication' || notification.type == 'admin_new_pro') ? AppTheme.primary : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatTime(context, notification.timestamp),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(date.year, date.month, date.day);
    final locale = Localizations.localeOf(context).languageCode;

    if (notificationDate.isAtSameMomentAs(today)) {
      return DateFormat('HH:mm').format(date);
    }
    return DateFormat.MMMd(locale).format(date);
  }
}
