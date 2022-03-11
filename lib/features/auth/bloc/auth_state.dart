part of 'auth_bloc.dart';

@immutable
class AuthState {
  final bool loggedIn;
  final bool previouslyLoggedIn;

  final String? loginResult;

  const AuthState({required this.loggedIn, required this.previouslyLoggedIn, this.loginResult});

  Future<String?> verifyCredentials() async {
    String? email = await getStoredEmail();
    String? password = await getStoredPassword();

    if (email != null && password != null) {
      String? loginResult = await login(email, password);
      return loginResult;
    }

    if (loginResult != null) {
      bool result = await verifyToken(loginResult!);
      return result ? loginResult! : null;
    }

    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          loggedIn == other.loggedIn &&
          previouslyLoggedIn == other.previouslyLoggedIn &&
          loginResult == other.loginResult;

  @override
  int get hashCode => loggedIn.hashCode ^ previouslyLoggedIn.hashCode ^ loginResult.hashCode;

  factory AuthState.fromMap(Map<String, dynamic> map) {
    return AuthState(
      loggedIn: map['loggedIn'] as bool,
      previouslyLoggedIn: map['previouslyLoggedIn'] as bool,
      loginResult: map['loginResult'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loggedIn': loggedIn,
      'previouslyLoggedIn': previouslyLoggedIn,
      'loginResult': loginResult,
    };
  }

  @override
  String toString() {
    return 'AuthState{loggedIn: $loggedIn, previouslyLoggedIn: $previouslyLoggedIn, loginResult: $loginResult}';
  }
}

