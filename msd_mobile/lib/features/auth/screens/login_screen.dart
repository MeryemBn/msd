import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/msd_logo.dart';
import '../../../shared/widgets/msd_button.dart';
import '../../../shared/widgets/msd_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
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
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: Icon(Icons.close, color: Colors.red.shade300, size: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.error) {
        setState(() => _errorMessage = next.errorMessage);
        ref.read(authProvider.notifier).resetState();
      }
    });

    final isLoading = ref.watch(authProvider).status == AuthStatus.loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const MsdLogo(size: 70),
              const SizedBox(height: 16),
              Text(
                'MSD',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 40),
              _buildErrorWidget(),
              MsdTextField(
                label: l10n.username,
                hint: l10n.usernameHint,
                controller: _usernameController,
              ),
              const SizedBox(height: 16),
              MsdTextField(
                label: l10n.password,
                hint: l10n.passwordHint,
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => GoRouter.of(context).push('/forgot-password'),
                  child: Text(
                    l10n.forgotPassword,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : AppTheme.textDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              MsdButton(
                text: l10n.login,
                isLoading: isLoading,
                onPressed: () {
                  setState(() => _errorMessage = null);
                  ref.read(authProvider.notifier).login(
                    _usernameController.text.trim(),
                    _passwordController.text.trim(),
                  );
                },
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(l10n.noAccount, style: const TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                  GestureDetector(
                    onTap: () => GoRouter.of(context).push('/role-selection'),
                    child: Text(
                      l10n.signUp,
                      style: TextStyle(
                        color: isDark ? AppTheme.primary : AppTheme.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
