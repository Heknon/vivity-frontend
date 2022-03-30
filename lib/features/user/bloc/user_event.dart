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
  final BuildContext context;
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
    required this.context,
  });
}

class UserRenewTokenEvent extends UserEvent {}

class UserUpdateProfilePictureEvent extends UserEvent {
  final File? picture;

  UserUpdateProfilePictureEvent(this.picture);
}

class UserAddFavoriteEvent extends UserEvent {
  final ItemModel item;

  UserAddFavoriteEvent(this.item);
}

class UserRemoveFavoriteEvent extends UserEvent {
  final ObjectId itemId;

  UserRemoveFavoriteEvent(this.itemId);
}

class BusinessUserFrontendUpdateItem extends UserEvent {
  final ItemModel item;

  BusinessUserFrontendUpdateItem(this.item);
}
