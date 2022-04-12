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

class AuthFailedState extends AuthLoggedOutState {
  final String? message;

  AuthFailedState({this.message});
}

class AuthLoggedOutState extends AuthState {

}
