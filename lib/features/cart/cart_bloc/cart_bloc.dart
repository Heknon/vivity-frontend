import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:vivity/features/item/models/item_model.dart';

import '../../../models/shipping_method.dart';
import '../../user/bloc/user_bloc.dart';
import 'cart_state.dart';

part 'cart_event.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  late bool registeredUserBloc = false;
  late bool initialized = false;

  CartBloc() : super(CartState(List.empty(growable: true), ShippingMethod.delivery)) {
    on<CartAddItemEvent>((event, emit) {
      CartState newState = state.copyWith();
      newState.addItem(event.item);

      emit(newState);
    });

    on<CartRemoveItemEvent>((event, emit) {
      CartState newState = state.copyWith();
      newState.removeItem(event.index);

      emit(newState);
    });

    on<CartIncrementItemEvent>((event, emit) {
      CartState newState = state.copyWith();
      newState.incrementQuantity(event.index);

      emit(newState);
    });

    on<CartDecrementItemEvent>((event, emit) {
      CartState newState = state.copyWith();
      newState.decrementQuantity(event.index);

      emit(newState);
    });

    on<CartShipmentMethodUpdateEvent>((event, emit) {
      CartState newState = state.copyWith();
      newState.updateShipmentMethod(event.shippingMethod);

      emit(newState);
    });

    on<CartDeleteItemEvent>((event, emit) {
      CartState newState = state.copyWith();
      newState.removeItem(event.index);

      emit(newState);
    });

    on<CartRegisterInitializer>((event, emit) {
      if (registeredUserBloc) return;

      event.userBloc.stream.listen((userState) {
        if (!initialized && userState is UserLoggedInState) {
          add(CartSyncToUserStateEvent(userState));
          initialized = true;
        }
      });

      registeredUserBloc = true;
    });

    on<CartSyncToUserStateEvent>((event, emit) {
      emit(CartState.fromState(event.state));
    });
  }
}
