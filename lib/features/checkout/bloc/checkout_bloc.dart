import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:vivity/features/checkout/checkout_service.dart';
import 'package:vivity/features/item/models/item_model.dart';
import '../../user/models/address.dart';
import 'package:vivity/models/payment_method.dart';
import 'package:vivity/models/shipping_method.dart';

part 'checkout_event.dart';

part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  CheckoutBloc() : super(CheckoutInitial()) {
    on<CheckoutInitializeEvent>((event, emit) async {
      CheckoutState state = CheckoutStateConfirmationStage(items: event.items, shippingMethod: event.shippingMethod, cuponCode: event.cuponCode);

      emit(CheckoutLoadingState());
      await state.init();
      emit(state);
    });

    on<CheckoutApplyShippingEvent>((event, emit) async {
      CheckoutState state = CheckoutStateShippingStage(
        items: (this.state as CheckoutStateConfirmationStage).items,
        shippingMethod: (this.state as CheckoutStateConfirmationStage).shippingMethod,
        cuponCode: (this.state as CheckoutStateConfirmationStage).cuponCode,
        shippingAddress: event.address,
      );

      emit(CheckoutLoadingState());
      await state.init();
      emit(state);
    });

    on<CheckoutSelectPaymentEvent>((event, emit) async {
      CheckoutState state = CheckoutStatePaymentStage(
        items: (this.state as CheckoutStateShippingStage).items,
        shippingMethod: (this.state as CheckoutStateShippingStage).shippingMethod,
        cuponCode: (this.state as CheckoutStateShippingStage).cuponCode,
        shippingAddress: (this.state as CheckoutStateShippingStage).shippingAddress,
        paymentMethod: event.paymentMethod,
      );

      emit(CheckoutLoadingState());
      await state.init();
      emit(state);
    });
  }
}
