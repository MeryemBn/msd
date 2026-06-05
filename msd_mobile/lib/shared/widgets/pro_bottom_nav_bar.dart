import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ProBottomNavBar extends StatelessWidget {
  final Widget child;

  const ProBottomNavBar({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/pro-home')) return 0;
    if (location.startsWith('/pro-agenda')) return 1;
    if (location.startsWith('/pro-revenus')) return 2;
    if (location.startsWith('/pro-profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final currentIndex = _locationToIndex(location);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == currentIndex) return;

          switch (index) {
            case 0:
              context.go('/pro-home');
              break;
            case 1:
              context.go('/pro-agenda');
              break;
            case 2:
              context.go('/pro-revenus');
              break;
            case 3:
              context.go('/pro-profile');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_rounded),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_outlined),
            label: l10n.agenda,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.attach_money_rounded),
            label: l10n.earnings,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
