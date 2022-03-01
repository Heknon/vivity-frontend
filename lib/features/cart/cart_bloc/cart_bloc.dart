import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fade_in_widget/fade_in_widget.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/item/models/item_model.dart';

import 'cart_state.dart';

part 'cart_event.dart';

class CartBloc extends HydratedBloc<CartEvent, CartState> {
  CartBloc() : super(CartState(List.empty(growable: true))) {
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
  }

  @override
  CartState fromJson(Map<String, dynamic> json) {
    return CartState.fromMap(json);
  }

  @override
  Map<String, dynamic> toJson(CartState state) {
    return state.toMap();
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
