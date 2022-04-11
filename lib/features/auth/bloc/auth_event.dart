part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String? otp;
  final bool stayLoggedIn;

  AuthLoginEvent(this.email, this.password, this.otp, this.stayLoggedIn);
}

class AuthHandlePre2FA extends AuthEvent {
  final AuthenticationResult authResult;

  AuthHandlePre2FA(this.authResult);
}

class AuthRegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;

  AuthRegisterEvent(this.email, this.password, this.name, this.phone);
}

class AuthConfirmationEvent extends AuthEvent {
  final bool isSilentLogin;

  AuthConfirmationEvent(this.isSilentLogin);
}

class AuthLogoutEvent extends AuthEvent {}
