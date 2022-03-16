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
}

class AuthLoggedOutState extends AuthState {
  const AuthLoggedOutState();
}

class AuthLoadingState extends AuthLoggedOutState {}

class AuthRegisterFailedState extends AuthLoggedOutState {
  final AuthenticationResult reason;

  const AuthRegisterFailedState(this.reason);
}

class AuthLoggedInState extends AuthState {
  final String token;

  const AuthLoggedInState({required this.token});

  /// Checks if current token is valid and returns it. if not valid generates a new one based on stored credentials or returns null.
  Future<String?> verifyCredentials() async {
    bool tokenIsGood = await verifyToken(token);
    if (tokenIsGood) {
      return token;
    }

    String? email = await getStoredEmail();
    String? password = await getStoredPassword();

    if (email != null && password != null) {
      String? loginResult = await login(email, password);
      return loginResult;
    }

    return null;
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthLoggedInState && runtimeType == other.runtimeType && token == other.token;

  @override
  int get hashCode => token.hashCode;

  factory AuthLoggedInState.fromMap(Map<String, dynamic> map) {
    return AuthLoggedInState(
      token: map["token"] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
    };
  }

  @override
  String toString() {
    return 'AuthState{token: $token}';
  }
}
