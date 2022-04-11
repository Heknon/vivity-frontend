part of 'user_bloc.dart';

@immutable
abstract class UserEvent {}

class UserLoginEvent extends UserEvent {
  final String accessToken;

  UserLoginEvent(this.accessToken);
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

class UserRenewTokenEvent extends UserEvent {
  final String accessToken;

  UserRenewTokenEvent(this.accessToken);
}

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

class UserFrontendUpdate extends UserEvent {
  final String? email;
  final String? phone;
  final UserOptions options;

  UserFrontendUpdate({
    required this.options,
    this.email,
    this.phone,
  });
}

class BusinessUserFrontendUpdateItem extends UserEvent {
  final ItemModel item;

//<editor-fold desc="Data Methods">

  BusinessUserFrontendUpdateItem({
    required this.item,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is BusinessUserFrontendUpdateItem && runtimeType == other.runtimeType && item == other.item);

  @override
  int get hashCode => item.hashCode;

  @override
  String toString() {
    return 'BusinessUserFrontendUpdateItem{' + ' item: $item,' + '}';
  }

  BusinessUserFrontendUpdateItem copyWith({
    ItemModel? item,
  }) {
    return BusinessUserFrontendUpdateItem(
      item: item ?? this.item,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item': this.item,
    };
  }

  factory BusinessUserFrontendUpdateItem.fromMap(Map<String, dynamic> map) {
    return BusinessUserFrontendUpdateItem(
      item: map['item'] as ItemModel,
    );
  }

//</editor-fold>
}

class BusinessUserFrontendUpdateOrder extends UserEvent {
  final Order order;

  BusinessUserFrontendUpdateOrder(this.order);
}

class UpdateProfileData extends UserEvent {
  final bool addresses;
  final bool orders;

  UpdateProfileData({this.addresses = true, this.orders = true});
}

class UpdateBusinessDataEvent extends UserEvent {
  UpdateBusinessDataEvent();
}
