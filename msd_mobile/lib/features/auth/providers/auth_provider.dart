import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/notification_history_service.dart';
import '../../profile/providers/profile_provider.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;
  Timer? _verificationTimer;

  AuthNotifier(this._authService, this._ref) : super(const AuthState(status: AuthStatus.initial)) {
    checkAuthStatus();
  }

  void _resetAllAppData() {
    debugPrint("🧹 Nettoyage des données de session...");
    // On vide le profil. Le chatbotProvider se réinitialisera automatiquement
    // car il observe (watch) l'accessToken dans son propre provider.
    _ref.read(profileProvider.notifier).clearProfile();
  }

  String? _getUserIdFromToken(String token) {
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken['sub'] as String?;
    } catch (e) {
      return null;
    }
  }

  List<String> _getRolesFromToken(String token) {
    try {
      final actualToken = token.startsWith('Bearer ') ? token.substring(7) : token;
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(actualToken);
      final List<String> allRoles = [];
      final realmAccess = decodedToken['realm_access'] as Map<String, dynamic>?;
      if (realmAccess != null && realmAccess['roles'] is Iterable) {
        allRoles.addAll((realmAccess['roles'] as Iterable).map((e) => e.toString()));
      }
      final resourceAccess = decodedToken['resource_access'] as Map<String, dynamic>?;
      if (resourceAccess != null) {
        for (var client in resourceAccess.values) {
          if (client is Map && client['roles'] is Iterable) {
            final roles = client['roles'];
            if (roles is Iterable) {
              allRoles.addAll(roles.map((e) => e.toString()));
            }
          }
        }
      }
      return allRoles;
    } catch (e) {
      return [];
    }
  }

  String _determineRole(List<String> roles) {
    final lowerRoles = roles.map((r) => r.toLowerCase()).toList();
    if (lowerRoles.contains('admin')) return 'admin';
    if (lowerRoles.contains('professional') || lowerRoles.contains('pro')) return 'professional';
    return 'patient';
  }

  Future<void> checkAuthStatus() async {
    final token = await _authService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        if (!JwtDecoder.isExpired(token)) {
          final userId = _getUserIdFromToken(token);
          final roles = _getRolesFromToken(token);
          if (userId != null) await notificationService.initHistoryForUser(userId);

          state = state.copyWith(
            status: AuthStatus.authenticated,
            accessToken: token,
            userRole: _determineRole(roles),
          );
        } else {
          state = state.copyWith(status: AuthStatus.unauthenticated);
        }
      } catch (e) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String username, String password, {bool silent = false}) async {
    if (username.isEmpty || password.isEmpty) {
      if (!silent) state = state.copyWith(status: AuthStatus.error, errorMessage: "Identifiants obligatoires");
      return;
    }

    _resetAllAppData();

    if (!silent) state = state.copyWith(status: AuthStatus.loading);
    try {
      final tokenResponse = await _authService.login(username, password);
      final userId = _getUserIdFromToken(tokenResponse.accessToken);
      final roles = _getRolesFromToken(tokenResponse.accessToken);
      final finalRole = _determineRole(roles);

      if (userId != null) await notificationService.initHistoryForUser(userId);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
        expiresIn: tokenResponse.expiresIn,
        refreshExpiresIn: tokenResponse.refreshExpiresIn,
        tokenType: tokenResponse.tokenType,
        userRole: finalRole,
      );
    } catch (e) {
      if (!silent) state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> signup({
    required String username,
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.signup(SignupRequest(
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        role: role,
      ));
      state = state.copyWith(
        status: AuthStatus.signupSuccess, 
        signupEmail: email,
        signupUsername: username,
        signupPassword: password,
        userRole: role,
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  void startEmailVerificationPolling() {
    _verificationTimer?.cancel();
    _verificationTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (state.status != AuthStatus.signupSuccess || 
          state.signupUsername == null || 
          state.signupPassword == null) {
        return;
      }
      try {
        await login(state.signupUsername!, state.signupPassword!, silent: true);
        _ref.read(profileProvider.notifier).loadProfile(silent: true);
        timer.cancel();
        _verificationTimer = null;
      } catch (e) {
        debugPrint("Polling check: still unverified...");
      }
    });
  }

  void stopEmailVerificationPolling() {
    _verificationTimer?.cancel();
    _verificationTimer = null;
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authService.forgotPassword(email);
      state = state.copyWith(status: AuthStatus.initial);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  void logout() async {
    await _authService.logout();
    await notificationHistoryService.closeBox();
    
    // On met à jour l'état d'abord pour déclencher la réactivité des autres providers
    state = const AuthState(status: AuthStatus.unauthenticated);
    
    _resetAllAppData();
  }

  void resetState() {
    state = state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null, signupEmail: null);
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(authService, ref));
