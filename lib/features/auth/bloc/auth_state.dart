part of 'auth_bloc.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthLoggedInState extends AuthState {
  final TokenContainer tokenContainer;

  AuthLoggedInState(this.tokenContainer);
}

class AuthLoadingState extends AuthState {}

class AuthLoggedOutState extends AuthState {
  final AuthenticationStatus? status;

  AuthLoggedOutState({this.status});
}
