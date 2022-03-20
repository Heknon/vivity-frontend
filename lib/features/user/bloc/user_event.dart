part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class UserLoginEvent extends UserEvent {
  final String token;

  UserLoginEvent(this.token);
}

class UserLogoutEvent extends UserEvent {}

class UserUpdateEvent extends UserEvent {}

class UserUpdateAddressesEvent extends UserEvent {
  final List<Address> addresses;

  UserUpdateAddressesEvent(this.addresses);
}
