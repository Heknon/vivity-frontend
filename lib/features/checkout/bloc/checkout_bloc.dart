import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/checkout/checkout_service.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/models/address.dart';
import 'package:vivity/models/payment_method.dart';
import 'package:vivity/models/shipping_method.dart';

part 'checkout_event.dart';

part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(CheckoutState(items: List.empty(), shippingMethod: ShippingMethod.pickup, cuponCode: null, paymentMethod: null)) {
    on<CheckoutInitializeEvent>((event, emit) {
      emit(CheckoutState(
        items: event.items,
        shippingMethod: event.shippingMethod,
        cuponCode: event.cuponCode,
        paymentMethod: state.paymentMethod
      ));
    });

    on<CheckoutApplyCupon>((event, emit) {
      emit(CheckoutState(
        items: state.items,
        shippingMethod: state.shippingMethod,
        cuponCode: event.cuponCode,
        paymentMethod: state.paymentMethod,
      ));
    });

    on<CheckoutApplyShippingEvent>((event, emit) {
      emit(CheckoutState(
        items: state.items,
        shippingMethod: state.shippingMethod,
        cuponCode: state.cuponCode,
        shippingAddress: event.address,
        paymentMethod: state.paymentMethod,
      ));
    });

    on<CheckoutSelectPaymentEvent>((event, emit) {
      emit(CheckoutState(
        items: state.items,
        shippingMethod: state.shippingMethod,
        cuponCode: state.cuponCode,
        paymentMethod: event.paymentMethod,
      ));
    });
  }
}
