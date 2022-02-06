import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/item/models/item_model.dart';

part 'cart_event.dart';

class CartBloc extends HydratedBloc<CartEvent, List<CartItemModel>> {
  CartBloc() : super(List.empty(growable: true)) {
    on<CartAddItemEvent>((event, emit) {
      state.add(event.item);
      emit(List.of(state));
    });

    on<CartRemoveItemEvent>((event, emit) {
      state.removeAt(event.index);
      emit(List.of(state));
    });

    on<CartIncrementItemEvent>((event, emit) {
      state[event.index].quantity++;
      emit(List.of(state));
    });

    on<CartDecrementItemEvent>((event, emit) {
      state[event.index].quantity--;
      emit(List.of(state));
    });
  }

  @override
  List<CartItemModel> fromJson(Map<String, dynamic> json) {
    return (json["items"] as List<dynamic>).map((e) => CartItemModel.fromMap(e)).toList();
  }

  @override
  Map<String, dynamic> toJson(List<CartItemModel> state) {
    return {
      "items": state.map((e) => e.toMap()).toList()
    };
  }
}
