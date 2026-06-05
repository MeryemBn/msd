import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../../shared/widgets/msd_button.dart';
import '../../../shared/widgets/msd_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  String? _errorMessage;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Widget _buildErrorWidget() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
      if (next.status == AuthStatus.signupSuccess) {
        context.go('/register-success');
      }
      if (next.status == AuthStatus.error) {
        setState(() => _errorMessage = next.errorMessage);
        ref.read(authProvider.notifier).resetState();
      }
    });

    final isLoading = ref.watch(authProvider).status == AuthStatus.loading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : AppTheme.textDark, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.role == 'professional' ? "Inscription Professionnel" : l10n.createAccount,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.registerSubtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                ),
              ),
              const SizedBox(height: 32),
              
              _buildErrorWidget(),

              Row(
                children: [
                  Expanded(
                    child: MsdTextField(
                      label: l10n.firstName,
                      hint: l10n.firstNameHint,
                      controller: _firstNameController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MsdTextField(
                      label: l10n.lastName,
                      hint: l10n.lastNameHint,
                      controller: _lastNameController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MsdTextField(
                label: l10n.username,
                hint: l10n.usernameHint,
                controller: _usernameController,
              ),
              const SizedBox(height: 16),
              MsdTextField(
                label: l10n.emailAddress,
                hint: l10n.emailHint,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              MsdTextField(
                label: l10n.password,
                hint: l10n.passwordMinChars,
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              MsdTextField(
                label: l10n.confirmPassword,
                hint: l10n.confirmPasswordHint,
                controller: _confirmController,
                isPassword: true,
              ),
              const SizedBox(height: 40),
              MsdButton(
                text: l10n.signUp,
                isLoading: isLoading,
                onPressed: () {
                  if (_passwordController.text != _confirmController.text) {
                    setState(() => _errorMessage = l10n.passwordsDoNotMatch);
                    return;
                  }
                  ref.read(authProvider.notifier).signup(
                    username: _usernameController.text.trim(),
                    email: _emailController.text.trim(),
                    firstName: _firstNameController.text.trim(),
                    lastName: _lastNameController.text.trim(),
                    password: _passwordController.text.trim(),
                    role: widget.role,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
