import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/business/models/order_item.dart';
import 'package:vivity/features/cart/bloc/cart_bloc.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/models/shipping_method.dart';

import '../../service/checkout_service.dart';

part 'checkout_confirm_event.dart';

part 'checkout_confirm_state.dart';

class CheckoutConfirmBloc extends Bloc<CheckoutConfirmEvent, CheckoutConfirmState> {
  final CheckoutService _checkoutService = CheckoutService();

  CheckoutConfirmBloc() : super(CheckoutConfirmUnloaded()) {
    on<CheckoutConfirmLoadEvent>((event, emit) async {
      emit(CheckoutConfirmLoading());
      CartBloc bloc = event.cartBloc;
      CartState cartState = bloc.state;
      if (cartState is! CartLoaded) throw Exception('Cart must be loaded to enter checkout stage');

      bloc.stream.listen((cartState) {
        if (cartState is CartBlocked && cartState is! CartLoading) {
          return emit(CheckoutConfirmUnloaded());
        }

        if (!isClosed) {
          add(CheckoutConfirmUpdateCartStateEvent(cartState));
        }
      });

      List<CartItemModel> items = cartState.items.map((e) => e).toList();
      CheckoutConfirmLoaded s = CheckoutConfirmLoaded(
        items: items,
        shippingMethod: ShippingMethod.delivery,
        cupon: "",
        deliveryCost: 0,
        cuponDiscount: 0,
        subtotal: cartState.total,
      );

      emit(s.copyWith(
        cuponDiscount: await calculateCupon(s),
        deliveryCost: await calculateDelivery(s),
      ));
    });

    on<CheckoutConfirmUpdateShippingEvent>((event, emit) async {
      CheckoutConfirmState s = state;
      if (s is! CheckoutConfirmLoaded) return;

      s = s.copyWith(
        shippingMethod: event.shippingMethod,
      );

      emit(s.copyWith(
        deliveryCost: await calculateDelivery(s),
      ));
    });

    on<CheckoutConfirmUpdateCuponEvent>((event, emit) async {
      CheckoutConfirmState s = state;
      if (s is! CheckoutConfirmLoaded) return;

      s = s.copyWith(
        cupon: event.cupon,
      );

      s = s.copyWith(
        cuponDiscount: await calculateCupon(s),
      );
      emit(s);
    });

    on<CheckoutConfirmUpdateCartStateEvent>((event, emit) async {
      if (event.state is! CartLoaded || state is! CheckoutConfirmLoaded) return;
      CheckoutConfirmLoaded s = (state as CheckoutConfirmLoaded).copyWith(items: (event.state as CartLoaded).items);
      emit(s.copyWith(
        subtotal: (event.state as CartLoaded).total,
        cuponDiscount: await calculateCupon(s),
        deliveryCost: await calculateDelivery(s),
      ));
    });
  }

  Future<double> calculateDelivery(CheckoutConfirmLoaded state) async {
    if (state.shippingMethod == ShippingMethod.delivery) {
      return calculateShipping(state);
    }

    return 0;
  }

  Future<double> calculateShipping(CheckoutConfirmLoaded state) async {
    AsyncSnapshot<double> deliverySnapshot =
        await _checkoutService.getShippingCost(address: null, items: state.items.map((e) => OrderItem.fromCartItem(e)).toList());
    double deliveryCost = deliverySnapshot.hasError || !deliverySnapshot.hasData ? 0 : deliverySnapshot.data!;

    return deliveryCost;
  }

  Future<double> calculateCupon(CheckoutConfirmLoaded state) async {
    AsyncSnapshot<double> cuponSnapshot = await _checkoutService.getCuponDiscount(cupon: state.cupon);
    double cuponDiscount = cuponSnapshot.hasError || !cuponSnapshot.hasData ? 0 : cuponSnapshot.data!;

    return cuponDiscount;
  }
}
