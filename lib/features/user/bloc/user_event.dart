part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class UserLoginEvent extends UserEvent {
  final String token;

  UserLoginEvent(this.token);
}

class UserLogoutEvent extends UserEvent {}

class UserUpdateEvent extends UserEvent {}
