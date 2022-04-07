part of 'auth_bloc.dart';

@immutable
abstract class AuthState {
  const AuthState();

  Future<bool> get previouslyLoggedIn async {
    SharedPreferences shared = await SharedPreferences.getInstance();

    if (!shared.containsKey("previouslyLoggedIn")) {
      return false;
    }

    return shared.getBool("previouslyLoggedIn")!;
  }

  /// Checks if current token is valid and returns it. if not valid generates a new one based on stored credentials or returns null.
  Future<AuthResult?> verifyCredentials() async {
    String? refreshToken = await getStoredRefreshToken();

    if (refreshToken != null && isRefreshTokenValid(refreshToken)) {
      return refreshAccessToken(refreshToken);
    }

    return null;
  }
}

class AuthLoggedOutState extends AuthState {
  final AuthenticationResult? status;

  AuthLoggedOutState({this.status});
}

class AuthLoadingState extends AuthLoggedOutState {}

class AuthRegisterFailedState extends AuthLoggedOutState {
  final AuthenticationResult reason;

  AuthRegisterFailedState(this.reason);
}

class AuthLoggedInState extends AuthState {
  final AuthResult authResult;

  const AuthLoggedInState({required this.authResult});

  @override
  Future<AuthResult?> verifyCredentials() async {
    if (isAccessTokenValid(authResult.accessToken)) {
      return authResult;
    }

    return super.verifyCredentials();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthLoggedInState && runtimeType == other.runtimeType && authResult == other.authResult;

  @override
  int get hashCode => authResult.hashCode;

  factory AuthLoggedInState.fromMap(Map<String, dynamic> map) {
    return AuthLoggedInState(
      authResult: AuthResult.fromMap(map["authResult"]),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authResult': authResult.toMap(),
    };
  }

  @override
  String toString() {
    return 'AuthState{authResult: $authResult}';
  }
}
