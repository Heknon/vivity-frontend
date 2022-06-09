import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/address/models/address.dart';
import 'package:vivity/features/business/models/order.dart';
import 'package:vivity/features/business/models/order_item.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/checkout/service/checkout_service.dart';
import 'package:vivity/features/checkout/shipping_page/bloc/shipping_bloc.dart';
import 'package:vivity/features/item/models/item_model.dart';

part 'payment_event.dart';

part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CheckoutService _checkoutService = CheckoutService();

  PaymentBloc() : super(PaymentUnloaded()) {
    on<PaymentLoadEvent>((event, emit) {
      emit(PaymentLoading());
      ShippingBloc bloc = event.shippingBloc;
      ShippingState shippingState = bloc.state;
      if (shippingState is! ShippingLoaded) throw Exception('Must have selected an address to proceed to payment');

      bloc.stream.listen((shippingState) {
        if (shippingState is ShippingUnloaded && shippingState is! ShippingLoading) {
          return emit(PaymentUnloaded());
        }

        if (!isClosed) add(PaymentShippingStateUpdate(shippingState));
      });

      emit(PaymentLoaded(shippingState: shippingState, selectedAddress: event.address));
    });

    on<PaymentPayEvent>((event, emit) async {
      PaymentState s = state;
      if (s is! PaymentLoaded) return;

      emit(PaymentProcessingPayment(selectedAddress: s.selectedAddress, shippingState: s.shippingState));

      Order order = buildOrderFromState(s);
      print('sending payment');
      AsyncSnapshot<Order> processedOrder = await _checkoutService.processOrder(
        order: order,
        cupon: s.shippingState.confirmationStageState.cupon,
        creditCardNumber: event.cardNumber,
        year: event.year,
        month: event.month,
        cvv: event.cvv,
        name: event.name,
      );

      if (processedOrder.hasError || !processedOrder.hasData) {
        return emit(PaymentFailedPayment(processedOrder.error?.toString() ?? 'Failed to process order.'));
      }

      emit(PaymentSuccessPayment(processedOrder.data!, s.shippingState.confirmationStageState.items.map((e) => e.item).toList()));
    });

    on<PaymentShippingStateUpdate>((event, emit) {
      PaymentState s = state;

      if (event.state is! ShippingLoaded || s is! PaymentLoaded) return;

      emit(s.copyWith(shippingState: event.state as ShippingLoaded));
    });
  }

  Order buildOrderFromState(PaymentLoaded payment) {
    List<CartItemModel> items = payment.shippingState.confirmationStageState.items;

    return Order(
      orderDate: DateTime.now(),
      items: items.map((e) => OrderItem.fromCartItem(e)).toList(),
      subtotal: payment.shippingState.confirmationStageState.subtotal,
      shippingCost: payment.shippingState.confirmationStageState.deliveryCost,
      cuponDiscount: payment.shippingState.confirmationStageState.cuponDiscount,
      total: payment.shippingState.confirmationStageState.total,
      address: payment.selectedAddress,
      orderId: ObjectId(),
    );
  }
}
