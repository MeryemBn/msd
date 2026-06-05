import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/msd_button.dart';
import '../../../shared/widgets/msd_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).forgotPassword(email);
      if (mounted) {
        setState(() {
          _emailSent = true;
        });
      }
    } catch (e) {
      // L'erreur est aussi gérée via ref.listen mais on peut capturer ici si besoin
    }
  }

  Widget _buildErrorWidget() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        setState(() => _errorMessage = next.errorMessage);
      }
    });

    final isLoading = ref.watch(authProvider).status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : AppTheme.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _emailSent ? _buildSuccessState(context, l10n) : _buildFormState(context, l10n, isLoading),
        ),
      ),
    );
  }

  Widget _buildFormState(BuildContext context, AppLocalizations l10n, bool isLoading) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.forgotPassword,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.forgotPasswordSubtitle,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textGrey,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        _buildErrorWidget(),
        MsdTextField(
          label: l10n.emailAddress,
          hint: l10n.emailHint,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 32),
        MsdButton(
          text: l10n.sendLink,
          isLoading: isLoading,
          onPressed: _handleResetPassword,
        ),
      ],
    );
  }

  Widget _buildSuccessState(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        const Spacer(flex: 2),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.primary.withOpacity(0.15) : AppTheme.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mail_outline,
            color: AppTheme.primary,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.emailSentTitle,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.emailSentSubtitle(_emailController.text),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textGrey,
            height: 1.6,
          ),
        ),
        const Spacer(flex: 2),
        MsdButton(
          text: l10n.backToLogin,
          onPressed: () => context.go('/login'),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
