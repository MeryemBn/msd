enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  signupSuccess,
  passwordChanged,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final String? accessToken;
  final String? refreshToken;
  final int? expiresIn;
  final int? refreshExpiresIn;
  final String? tokenType;
  final String? signupEmail;
  final String? signupUsername;
  final String? signupPassword;
  final String? userRole; // 'patient', 'professional', or 'admin'

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.refreshExpiresIn,
    this.tokenType,
    this.signupEmail,
    this.signupUsername,
    this.signupPassword,
    this.userRole,
  });

  bool get isAdmin => userRole == 'admin';
  bool get isProfessional => userRole == 'professional';
  bool get isPatient => userRole == 'patient';

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    int? refreshExpiresIn,
    String? tokenType,
    String? signupEmail,
    String? signupUsername,
    String? signupPassword,
    String? userRole,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      refreshExpiresIn: refreshExpiresIn ?? this.refreshExpiresIn,
      tokenType: tokenType ?? this.tokenType,
      signupEmail: signupEmail ?? this.signupEmail,
      signupUsername: signupUsername ?? this.signupUsername,
      signupPassword: signupPassword ?? this.signupPassword,
      userRole: userRole ?? this.userRole,
    );
  }
}
