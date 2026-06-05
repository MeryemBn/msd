import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../app/app_theme.dart';
import '../../features/admin/providers/admin_provider.dart';

class AdminBottomNavBar extends ConsumerWidget {
  final Widget child;

  const AdminBottomNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch adminProvider to keep polling active and reactive throughout the admin shell
    ref.watch(adminProvider);

    final location = GoRouterState.of(context).matchedLocation;
    final l10n = AppLocalizations.of(context)!;
    
    int currentIndex = 0;
    if (location.startsWith('/admin/pending')) {
      currentIndex = 1;
    } else if (location.startsWith('/admin/profile')) {
      currentIndex = 2;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/admin-dashboard');
                break;
              case 1:
                context.go('/admin/pending');
                break;
              case 2:
                context.go('/admin/profile');
                break;
            }
          },
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_rounded),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.pending_actions_rounded),
              label: l10n.pending,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_rounded),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
