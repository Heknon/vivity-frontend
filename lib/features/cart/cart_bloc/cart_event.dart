part of './cart_bloc.dart';

@immutable
abstract class CartEvent {}

class CartAddItemEvent extends CartEvent {
  final CartItemModel item;

  CartAddItemEvent(this.item);
}

class CartRemoveItemEvent extends CartEvent {
  final int index;

  CartRemoveItemEvent(this.index);
}

class CartIncrementItemEvent extends CartEvent {
  final int index;

  CartIncrementItemEvent(this.index);
}

class CartDecrementItemEvent extends CartEvent {
  final int index;

  CartDecrementItemEvent(this.index);
}

class CartDeleteItemEvent extends CartEvent {
  final int index;

  CartDeleteItemEvent(this.index);
}

class CartShipmentMethodUpdateEvent extends CartEvent {
  final ShippingMethod shippingMethod;

  CartShipmentMethodUpdateEvent(this.shippingMethod);
}

class CartRegisterInitializer extends CartEvent {
  final UserBloc userBloc;

  CartRegisterInitializer(this.userBloc);
}

class CartSyncToUserStateEvent extends CartEvent {
  final UserLoggedInState state;

  CartSyncToUserStateEvent(this.state);
}
