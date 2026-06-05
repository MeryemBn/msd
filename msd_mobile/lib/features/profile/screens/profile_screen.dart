import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/auth_user.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../models/medical_record.dart';
import '../../sos/shared/models/sos_enums.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'fr': return 'Français';
      case 'en': return 'English';
      case 'ar': return 'العربية';
      default: return 'Français';
    }
  }

  String _formatServiceType(String? type, AppLocalizations l10n) {
    if (type == null) return '-';
    final t = type.toUpperCase();
    if (t == 'DOCTOR') return l10n.doctor;
    if (t == 'NURSE') return l10n.nurse;
    if (t == 'AMBULANCE') return l10n.ambulance;
    return type;
  }

  String _getValidationStatusLabel(ProfileState state, AppLocalizations l10n) {
    if (state.isValidated) return l10n.validated;
    if (state.isRejected) return l10n.rejected;
    return l10n.pending;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);
    final settings = ref.watch(settingsProvider);
    final user = profileState.userProfile;
    final pro = profileState.proProfile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String? authRole = authState.userRole;
    final bool isAdmin = authRole == 'admin';
    final bool isPatient = authRole == 'patient';
    final bool isPro = authRole == 'professional' || (user?.isProfessional == true && !isPatient && !isAdmin);
    
    final roleLabel = isAdmin ? "Administrateur" : (isPro ? l10n.professional : l10n.iAmPatient);

    if (profileState.isLoading && user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  await context.push('/profile/edit');
                  if (mounted) ref.read(profileProvider.notifier).loadProfile();
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.fieldBgDark : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.edit_outlined, size: 22, color: isDark ? Colors.white70 : AppTheme.textDark),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileProvider.notifier).loadProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(user?.fullName ?? l10n.user, roleLabel),
              const SizedBox(height: 32),

              _buildSectionTitle(l10n.personalInfo),
              _buildInfoCard(context, [
                if (user?.fullName != null && user!.fullName != 'Utilisateur')
                  _InfoTile(icon: Icons.person_outline, label: l10n.fullName, value: user.fullName),
                if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty)
                  _InfoTile(icon: Icons.phone_outlined, label: l10n.phone, value: user.phoneNumber!),
                if (user?.email != null && user!.email!.isNotEmpty)
                  _InfoTile(icon: Icons.mail_outline, label: l10n.email, value: user.email!),
                if ((user?.address != null && user!.address!.isNotEmpty) || (user?.city != null && user!.city!.isNotEmpty))
                  _InfoTile(
                    icon: Icons.location_on_outlined,
                    label: l10n.address,
                    value: [user?.address, user?.city].where((s) => s != null && s.isNotEmpty).join(', '),
                  ),
              ]),

              if (isPro) ...[
                if (pro != null) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle(l10n.professionalInfo.toUpperCase()),
                  _buildInfoCard(context, [
                    _InfoTile(icon: Icons.work_outline, label: l10n.occupation, value: _formatServiceType(pro.type, l10n)),
                    _buildProDetailsTile(context, pro, l10n),
                    _InfoTile(
                      icon: Icons.verified_user_outlined,
                      label: l10n.validationStatus,
                      value: _getValidationStatusLabel(profileState, l10n),
                      iconColor: profileState.isValidated ? Colors.green : (profileState.isRejected ? Colors.red : Colors.orange),
                    ),
                  ]),
                ]
              ] else if (isPatient) ...[
                _buildMedicalSection(context, user?.medicalRecords ?? [], l10n),
              ],

              const SizedBox(height: 24),
              _buildSectionTitle(l10n.settings),
              _buildInfoCard(context, [
                _SwitchTile(
                  icon: Icons.notifications_none_rounded,
                  label: l10n.notifications,
                  value: settings.notificationsEnabled,
                  onChanged: (v) => ref.read(settingsProvider.notifier).toggleNotifications(v),
                ),
                _ArrowTile(
                  icon: Icons.language_rounded,
                  label: l10n.language,
                  value: _getLanguageName(settings.locale),
                  onTap: () => _showLanguageDialog(context, ref, settings.locale, l10n),
                ),
                _SwitchTile(
                  icon: Icons.dark_mode_outlined,
                  label: l10n.darkMode,
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (v) => ref.read(settingsProvider.notifier).toggleTheme(v),
                ),
              ]),

              const SizedBox(height: 32),
              _buildLogoutButton(context, ref, l10n),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalSection(BuildContext context, List<MedicalRecord> records, AppLocalizations l10n) {
    final bloodType = records.where((r) => r.type == 'BLOOD_TYPE').map((r) => r.description).firstOrNull;
    final allergies = records.where((r) => r.type == 'ALLERGY').map((r) => r.description).where((d) => d.trim().isNotEmpty).toList();
    final history = records.where((r) => r.type == 'MEDICAL_HISTORY').map((r) => r.description).where((d) => d.trim().isNotEmpty).toList();
    final chronic = records.where((r) => r.type == 'CHRONIC_DISEASE').map((r) => r.description).where((d) => d.trim().isNotEmpty).toList();

    return Column(
      children: [
        const SizedBox(height: 24),
        _buildSectionTitle(l10n.medicalInfo),
        _buildInfoCard(context, [
          if (bloodType != null)
            _InfoTile(icon: Icons.water_drop_outlined, iconColor: Colors.redAccent, label: l10n.bloodType, value: bloodType),
          
          if (allergies.isNotEmpty)
            _buildChipsTile(l10n.allergies, allergies, Icons.warning_amber_rounded, Colors.orange),
            
          if (history.isNotEmpty)
            _buildChipsTile(l10n.history, history, Icons.history, Colors.blue),
            
          if (chronic.isNotEmpty)
            _buildChipsTile("Maladies Chroniques", chronic, Icons.favorite_border_rounded, Colors.red),

          if (bloodType == null && allergies.isEmpty && history.isEmpty && chronic.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(l10n.noneProvided, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            )
        ]),
      ],
    );
  }

  Widget _buildChipsTile(String label, List<String> items, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: items.map((item) => Chip(
                    label: Text(item, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                    backgroundColor: color.withOpacity(0.1),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProDetailsTile(BuildContext context, ProfessionalProfile pro, AppLocalizations l10n) {
    final proType = pro.type?.toUpperCase();
    if (proType == 'DOCTOR') {
      final specValue = pro.specialty?.toLowerCase();
      final spec = Specialty.values.firstWhere(
        (s) => s.toJson().toLowerCase() == specValue, 
        orElse: () => Specialty.medecineGenerale
      );
      return _InfoTile(icon: Icons.stars_outlined, label: l10n.specialty, value: spec.getLabel(l10n));
    } else if (proType == 'AMBULANCE') {
      final List<String> types = (pro.specialty ?? "").split(',')
          .where((String t) => t.trim().isNotEmpty)
          .map((String t) {
        try {
          final cleanT = t.trim().toLowerCase();
          return AmbulanceType.values.firstWhere((at) => at.toJson().toLowerCase() == cleanT).getLabel(l10n);
        } catch (_) {
          return t;
        }
      })
          .toList();

      if (types.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.local_shipping_outlined, color: AppTheme.textGrey, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.ambulanceType, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: types.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                      ),
                      child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (proType == 'NURSE') {
      return _InfoTile(icon: Icons.medical_services_outlined, label: l10n.specialty, value: Specialty.soinsADomicile.getLabel(l10n));
    }
    return const SizedBox.shrink();
  }

  Widget _buildHeader(String name, String role) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF3DD6C0), Color(0xFF2DBFAD)]),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(role, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _showLogoutDialog(context, ref, l10n),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          foregroundColor: Colors.redAccent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 20),
            const SizedBox(width: 8),
            Text(l10n.logout, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
            child: Text(l10n.logout, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, Locale currentLocale, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              label: 'Français',
              selected: currentLocale.languageCode == 'fr',
              onTap: () {
                ref.read(settingsProvider.notifier).setLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
            _LanguageOption(
              label: 'English',
              selected: currentLocale.languageCode == 'en',
              onTap: () {
                ref.read(settingsProvider.notifier).setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            _LanguageOption(
              label: 'العربية',
              selected: currentLocale.languageCode == 'ar',
              onTap: () {
                ref.read(settingsProvider.notifier).setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _InfoTile({required this.icon, required this.label, required this.value, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: (iconColor ?? Colors.grey).withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor ?? (isDark ? Colors.white70 : AppTheme.textGrey), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: isDark ? Colors.white70 : AppTheme.textGrey, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: AppTheme.primary),
        ],
      ),
    );
  }
}

class _ArrowTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ArrowTile({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: isDark ? Colors.white70 : AppTheme.textGrey, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
            Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.textGrey)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textGrey),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected ? const Icon(Icons.check, color: AppTheme.primary) : null,
      onTap: onTap,
    );
  }
}
