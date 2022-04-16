import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/cart/bloc/cart_bloc.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/models/shipping_method.dart';

part 'checkout_confirm_event.dart';

part 'checkout_confirm_state.dart';

class CheckoutConfirmBloc extends Bloc<CheckoutConfirmEvent, CheckoutConfirmState> {
  CheckoutConfirmBloc() : super(CheckoutConfirmUnloaded()) {
    on<CheckoutConfirmLoadEvent>((event, emit) {
      emit(CheckoutConfirmLoading());
      CartBloc bloc = event.cartBloc;
      CartState cartState = bloc.state;
      if (cartState is! CartLoaded) throw Exception('Cart must be loaded to enter checkout stage');

      bloc.stream.listen((cartState) {
        if (cartState is CartBlocked && cartState is! CartLoading) {
          return emit(CheckoutConfirmUnloaded());
        }

        if (cartState is! CartLoaded || state is! CheckoutConfirmLoaded) return;
        CheckoutConfirmLoaded s = (state as CheckoutConfirmLoaded).copyWith(items: cartState.items);
        emit(s.copyWith(
          cuponDiscount: calculateCupon(s),
          deliveryCost: calculateDelivery(s),
        ));
      });

      CheckoutConfirmLoaded s = CheckoutConfirmLoaded(
        items: cartState.items.map((e) => e.copyWith()).toList(),
        shippingMethod: ShippingMethod.delivery,
        cupon: "",
        deliveryCost: 0,
        cuponDiscount: 0,
        subtotal: cartState.total,
      );

      emit(s.copyWith(
        cuponDiscount: calculateCupon(s),
        deliveryCost: calculateDelivery(s),
      ));
    });

    on<CheckoutConfirmUpdateShippingEvent>((event, emit) {
      CheckoutConfirmState s = state;
      if (s is! CheckoutConfirmLoaded) return;

      s = s.copyWith(
        shippingMethod: event.shippingMethod,
      );

      emit(s.copyWith(
        deliveryCost: calculateDelivery(s),
      ));
    });

    on<CheckoutConfirmUpdateCuponEvent>((event, emit) {
      CheckoutConfirmState s = state;
      if (s is! CheckoutConfirmLoaded) return;

      s = s.copyWith(
        cupon: event.cupon,
      );

      emit(s.copyWith(
        cuponDiscount: calculateCupon(s),
      ));
    });
  }

  double calculateDelivery(CheckoutConfirmLoaded state) {
    if (state.shippingMethod == ShippingMethod.delivery) {
      return calculateShipping(state);
    }

    return 0;
  }

  double calculateShipping(CheckoutConfirmLoaded state) {
    return state.items.length * 1.25;
  }

  double calculateCupon(CheckoutConfirmLoaded state) {
    if (state.cupon.isEmpty) {
      return 0;
    } else {
      return state.subtotal * 0.1;
    }
  }
}
