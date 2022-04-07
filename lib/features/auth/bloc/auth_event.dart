part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;
  final String? otp;
  final bool stayLoggedIn;
  final void Function(Response?)? onFail;

  AuthLoginEvent(
    this.email,
    this.password,
    this.otp,
    this.stayLoggedIn, {
    this.onFail,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthLoginEvent &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password &&
          stayLoggedIn == other.stayLoggedIn;

  @override
  int get hashCode => email.hashCode ^ password.hashCode ^ stayLoggedIn.hashCode;
}

class AuthHandlePre2FA extends AuthEvent {
  final RegisterResult registerResult;

  AuthHandlePre2FA(this.registerResult);
}

class AuthRegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;

  AuthRegisterEvent(this.email, this.password, this.name, this.phone);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthRegisterEvent &&
          runtimeType == other.runtimeType &&
          email == other.email &&
          password == other.password &&
          name == other.name &&
          phone == other.phone;

  @override
  int get hashCode => email.hashCode ^ password.hashCode ^ name.hashCode ^ phone.hashCode;
}

class AuthConfirmationEvent extends AuthEvent {
  final bool isSilentLogin;

  AuthConfirmationEvent(this.isSilentLogin);
}

class AuthLogoutEvent extends AuthEvent {}
