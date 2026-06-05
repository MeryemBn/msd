import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../shared/widgets/msd_logo.dart';
import '../../../shared/widgets/msd_button.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Petit délai pour laisser l'animation du logo s'afficher
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authState = ref.read(authProvider);
    _handleRedirection(authState);
  }

  void _handleRedirection(AuthState state) {
    if (state.status == AuthStatus.authenticated) {
      if (state.userRole == 'professional') {
        context.go('/pro-home');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(authProvider, (previous, next) {
      _handleRedirection(next);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            const MsdLogo(size: 90),
            const SizedBox(height: 24),
            Text(
              'MSD',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.textDark,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.splashSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textGrey,
                height: 1.5,
              ),
            ),
            const Spacer(flex: 3),
            
            if (authState.status == AuthStatus.unauthenticated)
              MsdButton(
                text: l10n.getStarted,
                onPressed: () => context.go('/login'),
              )
            else
              const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                  strokeWidth: 3,
                ),
              ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
