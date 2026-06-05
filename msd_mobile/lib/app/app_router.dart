import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/role_selection_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/verification_email_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/notification_screen.dart';
import '../features/home/screens/professional_home_screen.dart';
import '../features/home/screens/professional_reviews_screen.dart';
import '../features/medications/screens/medication_timeline_screen.dart';
import '../features/medications/screens/alarm_ring_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/profile/screens/complete_personal_info_screen.dart';
import '../features/profile/screens/complete_medical_info_screen.dart';
import '../features/profile/screens/professional_setup_screen.dart';
import '../features/profile/screens/document_upload_screen.dart';
import '../features/profile/screens/pending_validation_screen.dart';
import '../features/profile/screens/professional_rejected_screen.dart';
import '../features/profile/screens/professional_revenue_screen.dart';
import '../features/profile/screens/professional_pricing_screen.dart';
import '../features/profile/providers/profile_provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/providers/auth_state.dart';
import '../features/sos/shared/screens/sos_requests_history_screen.dart';
import '../features/sos/shared/screens/sos_tracking_map_screen.dart';
import '../features/sos/shared/screens/professional_agenda_screen.dart';
import '../features/sos/shared/models/sos_request.dart';
import '../features/sos/teleconsult/screens/teleconsult_call_screen.dart';
import '../shared/widgets/app_bottom_nav_bar.dart';
import '../shared/widgets/pro_bottom_nav_bar.dart';
import '../shared/widgets/admin_bottom_nav_bar.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/professional_review_detail_screen.dart';
import '../features/admin/screens/admin_professionals_screen.dart';
import '../features/admin/screens/admin_requests_screen.dart';
import '../features/admin/screens/admin_patients_screen.dart';
import '../features/admin/models/professional_review.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _patientShellKey = GlobalKey<NavigatorState>();
final _proShellKey = GlobalKey<NavigatorState>();
final _adminShellKey = GlobalKey<NavigatorState>();

class RouterRefreshListenable extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerRefreshListenable = RouterRefreshListenable();

final appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  refreshListenable: routerRefreshListenable,
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final authState = container.read(authProvider);
    final profileState = container.read(profileProvider);

    final isAuthPage = state.matchedLocation == '/login' || 
                       state.matchedLocation == '/register' ||
                       state.matchedLocation == '/role-selection' ||
                       state.matchedLocation == '/register-success' ||
                       state.matchedLocation == '/forgot-password' ||
                       state.matchedLocation == '/';

    if (authState.status != AuthStatus.authenticated) {
      if (authState.status == AuthStatus.signupSuccess && state.matchedLocation == '/register-success') {
        return null;
      }
      return isAuthPage ? null : '/login';
    }

    if (authState.isAdmin) {
      if (isAuthPage || state.matchedLocation == '/home' || state.matchedLocation == '/pro-home') {
        return '/admin-dashboard';
      }
      return null;
    }

    final user = profileState.userProfile;
    if (user == null || profileState.isLoading) return null;

    final bool isPatient = authState.userRole == 'patient';
    final bool isPro = !isPatient && (authState.userRole == 'professional' || user.isProfessional);

    if (isPro && profileState.isRejected) {
      if (state.matchedLocation != '/profile/pro-rejected') return '/profile/pro-rejected';
      return null;
    }

    if (!user.isProfileComplete) {
      if (!state.matchedLocation.startsWith('/profile/')) return '/profile/complete-personal';
      return null;
    }

    if (isPro && !profileState.isValidated) {
      if (state.matchedLocation != '/profile/pro-waiting') return '/profile/pro-waiting';
      return null;
    }

    if (isAuthPage) return isPro ? '/pro-home' : '/home';

    if (isPro) {
      if (state.matchedLocation == '/home') return '/pro-home';
    } else {
      if (state.matchedLocation.startsWith('/profile/pro-') || state.matchedLocation == '/pro-home') return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/role-selection', builder: (context, state) => const RoleSelectionScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'patient';
        return RegisterScreen(role: role);
      },
    ),
    GoRoute(path: '/register-success', builder: (context, state) => const VerificationEmailScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),

    // Admin Shell
    ShellRoute(
      navigatorKey: _adminShellKey,
      builder: (context, state, child) => AdminBottomNavBar(child: child),
      routes: [
        GoRoute(path: '/admin-dashboard', builder: (context, state) => const AdminDashboardScreen()),
        GoRoute(path: '/admin/pending', builder: (context, state) => const AdminProfessionalsScreen(initialFilter: 'PENDING')),
        GoRoute(path: '/admin/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),

    // Other Admin Routes
    GoRoute(path: '/admin/professionals', builder: (context, state) => const AdminProfessionalsScreen()),
    GoRoute(path: '/admin/requests', builder: (context, state) => const AdminRequestsScreen()),
    GoRoute(path: '/admin/patients', builder: (context, state) => const AdminPatientsScreen()),
    GoRoute(
      path: '/admin/professional-detail', 
      builder: (context, state) => ProfessionalReviewDetailScreen(review: state.extra as ProfessionalReview)
    ),

    // Wizard Profil
    GoRoute(path: '/profile/complete-personal', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const CompletePersonalInfoScreen()),
    GoRoute(path: '/profile/medical-info', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const CompleteMedicalInfoScreen()),
    GoRoute(path: '/profile/pro-setup', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const ProfessionalSetupScreen()),
    GoRoute(path: '/profile/pro-upload', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const DocumentUploadScreen()),
    GoRoute(path: '/profile/pro-waiting', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const PendingValidationScreen()),
    GoRoute(path: '/profile/pro-rejected', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const ProfessionalRejectedScreen()),

    // Patient Shell
    ShellRoute(
      navigatorKey: _patientShellKey,
      builder: (context, state, child) => AppBottomNavBar(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/medications', builder: (context, state) => MedicationTimelineScreen(targetIntakeLogId: state.uri.queryParameters['intakeLogId'])),
        GoRoute(path: '/requests', builder: (context, state) => const SosRequestsHistoryScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),

    // Pro Shell
    ShellRoute(
      navigatorKey: _proShellKey,
      builder: (context, state, child) => ProBottomNavBar(child: child),
      routes: [
        GoRoute(path: '/pro-home', builder: (context, state) => const ProfessionalHomeScreen()),
        GoRoute(path: '/pro-agenda', builder: (context, state) => const ProfessionalAgendaScreen()),
        GoRoute(path: '/pro-revenus', builder: (context, state) => const ProfessionalRevenueScreen()),
        GoRoute(path: '/pro-profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),

    GoRoute(path: '/pro-pricing', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const ProfessionalPricingScreen()),
    GoRoute(path: '/profile/edit', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const EditProfileScreen()),
    GoRoute(path: '/notifications', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => const NotificationScreen()),
    GoRoute(path: '/sos/tracking', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => SosTrackingMapScreen(request: state.extra as SosRequest)),
    GoRoute(path: '/alarm-ring', parentNavigatorKey: _rootNavigatorKey, builder: (context, state) => AlarmRingScreen(alarmSettings: state.extra as AlarmSettings)),
    GoRoute(
      path: '/teleconsult-call',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        return TeleconsultCallScreen(roomName: extras['roomName'], jwt: extras['jwt'], displayName: extras['displayName'], email: extras['email']);
      },
    ),
    GoRoute(
      path: '/professional/reviews',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ProfessionalReviewsScreen(
          professionalId: extra?['id'],
          professionalName: extra?['name'],
        );
      },
    ),
  ],
);

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.listen(authProvider, (previous, next) { 
    if (previous?.status != next.status) {
      if (next.status == AuthStatus.authenticated && !next.isAdmin) {
        ref.read(profileProvider.notifier).loadProfile();
      }
      routerRefreshListenable.refresh(); 
    }
  });
  ref.listen(profileProvider, (previous, next) { 
    if (previous?.isLoading != next.isLoading || 
        previous?.userProfile?.isProfileComplete != next.userProfile?.isProfileComplete || 
        previous?.userProfile?.statusValidation != next.userProfile?.statusValidation) {
      routerRefreshListenable.refresh();
    }
  });
  return appRouter;
});
