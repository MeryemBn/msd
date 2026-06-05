import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class PendingValidationScreen extends ConsumerWidget {
  const PendingValidationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Écouter le changement de statut en temps réel
    ref.listen<ProfileState>(profileProvider, (previous, next) {
      if (next.isValidated) {
        context.go('/pro-home');
      } else if (next.isRejected) {
        context.go('/profile/pro-rejected');
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                size: 80,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.validationPendingTitle ?? 'Vérification en cours',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.validationPendingMessage ?? 'Nos médecins conseils vérifient vos documents. Cela prend généralement moins de 24h pour garantir la sécurité de la plateforme.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => ref.read(profileProvider.notifier).loadProfile(),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.refresh ?? 'Actualiser mon statut'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
              child: Text(
                l10n.logout,
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
