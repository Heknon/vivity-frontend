import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/cart/repo/cart_repository.dart';
import 'package:vivity/helpers/list_utils.dart';

import '../../../models/shipping_method.dart';

part 'cart_event.dart';

part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartRepository _cartRepository = CartRepository();

  CartBloc() : super(CartBlocked()) {
    on<CartSyncEvent>((event, emit) async {
      emit(CartLoading());

      List<CartItemModel> cartItems = await _cartRepository.getCart(update: true, fetchImages: true);

      emit(CartLoaded(items: cartItems));
    });

    on<CartAddItemEvent>((event, emit) {
      CartState newState = state;
      if (newState is! CartLoaded) return;

      List<CartItemModel> newItems = safeItemAdd(newState.items, event.item);

      emit(newState.copyWith(items: newItems));

      _cartRepository.replaceCart(cartItems: newItems, updateDatabase: true, fetchImages: true, update: true);
    });

    on<CartRemoveItemEvent>((event, emit) {
      CartState newState = state;
      if (newState is! CartLoaded) return;

      List<CartItemModel> newItems = newState.items.safeIndexEdit(
        event.index,
        edit: (prev) => null,
      );

      emit(newState.copyWith(items: newItems));
      _cartRepository.replaceCart(cartItems: newItems, updateDatabase: true);
    });

    on<CartIncrementItemEvent>((event, emit) {
      CartState newState = state;
      if (newState is! CartLoaded) return;

      List<CartItemModel> newItems = newState.items.safeIndexEdit(
        event.index,
        edit: (prev) => prev.copyWith(quantity: prev.quantity + 1),
      );

      emit(newState.copyWith(items: newItems));
      _cartRepository.replaceCart(cartItems: newItems, updateDatabase: true);
    });

    on<CartDecrementItemEvent>((event, emit) {
      CartState newState = state;
      if (newState is! CartLoaded) return;

      List<CartItemModel> newItems = newState.items.safeIndexEdit(
        event.index,
        edit: (prev) => prev.copyWith(quantity: prev.quantity - 1),
      );

      emit(newState.copyWith(items: newItems));
      _cartRepository.replaceCart(cartItems: newItems, updateDatabase: true);
    });

    on<CartShipmentMethodUpdateEvent>((event, emit) {
      CartState newState = state;
      if (newState is! CartLoaded) return;

      emit(newState.copyWith(shippingMethod: event.shippingMethod));
    });
  }

  List<CartItemModel> safeItemAdd(List<CartItemModel> items, CartItemModel item) {
    List<CartItemModel> newList = List.empty(growable: true);
    bool added = false;

    for (CartItemModel cartItem in items) {
      if (item.looseEquals(cartItem)) {
        newList.add(cartItem.copyWith(quantity: item.quantity + cartItem.quantity));
        added = true;
        continue;
      }
      newList.add(cartItem);
    }

    if (!added) newList.add(item);
    return newList;
  }
}