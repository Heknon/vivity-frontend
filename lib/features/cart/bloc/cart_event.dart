part of './cart_bloc.dart';

@immutable
abstract class CartEvent {}

class CartSyncEvent extends CartEvent {}

class CartAddItemEvent extends CartEvent {
  final CartItemModel item;

  CartAddItemEvent(this.item);
}

class CartRemoveItemEvent extends CartEvent {
  final int hashcode;

  CartRemoveItemEvent(this.hashcode);
}

class CartIncrementItemEvent extends CartEvent {
  final int index;

  CartIncrementItemEvent(this.index);
}

class CartDecrementItemEvent extends CartEvent {
  final int index;

  CartDecrementItemEvent(this.index);
}
