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

class UserRegisterBusinessEvent extends UserEvent {
  final String businessName;
  final String businessEmail;
  final String businessPhone;
  final String businessNationalId;
  final File ownerId;
  final LatLng location;

  UserRegisterBusinessEvent({
    required this.businessName,
    required this.businessEmail,
    required this.businessPhone,
    required this.businessNationalId,
    required this.ownerId,
    required this.location,
  });
}
