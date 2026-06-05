import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/msd_button.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class VerificationEmailScreen extends ConsumerStatefulWidget {
  const VerificationEmailScreen({super.key});

  @override
  ConsumerState<VerificationEmailScreen> createState() => _VerificationEmailScreenState();
}

class _VerificationEmailScreenState extends ConsumerState<VerificationEmailScreen> {
  late AuthNotifier _authNotifier;

  @override
  void initState() {
    super.initState();
    _authNotifier = ref.read(authProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authNotifier.startEmailVerificationPolling();
    });
  }

  @override
  void dispose() {
    // Utilisation du notifier capturé pour éviter "Bad state: Cannot use ref after disposed"
    _authNotifier.stopEmailVerificationPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final signupEmail = ref.watch(authProvider).signupEmail ?? l10n.email;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary.withOpacity(0.2)),
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      color: colorScheme.primary,
                      size: 35,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                l10n.verifyEmailTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.verifyEmailSubtitle(signupEmail),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurface.withOpacity(0.6),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      l10n.loading,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).resetState();
                  context.go('/login');
                },
                child: Text(
                  l10n.backToLogin,
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
