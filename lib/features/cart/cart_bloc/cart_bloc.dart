import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:vivity/features/item/models/item_model.dart';

import '../../../models/shipping_method.dart';
import '../../user/bloc/user_bloc.dart';
import 'cart_state.dart';

part 'cart_event.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState(List.empty(growable: true), ShippingMethod.delivery)) {
    on<CartAddItemEvent>((event, emit) {
      emit(state.copyWith().addItem(event.item).copyWith());
    });

    on<CartRemoveItemEvent>((event, emit) {
      emit(state.copyWith().removeItem(event.index).copyWith());
    });

    on<CartIncrementItemEvent>((event, emit) {
      emit(state.copyWith().incrementQuantity(event.index).copyWith());
    });

    on<CartDecrementItemEvent>((event, emit) {
      emit(state.copyWith().decrementQuantity(event.index).copyWith());
    });

    on<CartShipmentMethodUpdateEvent>((event, emit) {
      emit(state.copyWith().updateShipmentMethod(event.shippingMethod).copyWith());
    });

    on<CartDeleteItemEvent>((event, emit) {
      emit(state.copyWith().removeItem(event.index).copyWith());
    });

    on<CartSyncToUserStateEvent>((event, emit) {
      emit(CartState.fromState(event.state));
    });
  }

  @override
  void onTransition(Transition<CartEvent, CartState> transition) {
    super.onTransition(transition);
  }

  @override
  void onEvent(CartEvent event) {
    super.onEvent(event);
  }

  @override
  void onChange(Change<CartState> change) {
    super.onChange(change);
  }
}
