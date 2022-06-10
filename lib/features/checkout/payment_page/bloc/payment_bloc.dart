import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/address/models/address.dart';
import 'package:vivity/features/business/models/order.dart';
import 'package:vivity/features/business/models/order_item.dart';
import 'package:vivity/features/cart/bloc/cart_bloc.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/cart/repo/cart_repository.dart';
import 'package:vivity/features/checkout/service/checkout_service.dart';
import 'package:vivity/features/checkout/shipping_page/bloc/shipping_bloc.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/user/repo/user_repository.dart';

import '../../../../helpers/helper.dart';

part 'payment_event.dart';

part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CheckoutService _checkoutService = CheckoutService();
  final UserRepository _userRepository = UserRepository();
  final CartRepository _cartRepository = CartRepository();

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

      await _userRepository.getUser(update: true);
      event.cartBloc.add(CartSyncEvent());
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
      subtotal: roundDouble(payment.shippingState.confirmationStageState.subtotal, 3),
      shippingCost: roundDouble(payment.shippingState.confirmationStageState.deliveryCost, 3),
      cuponDiscount: roundDouble(payment.shippingState.confirmationStageState.cuponDiscount, 3),
      total: roundDouble(payment.shippingState.confirmationStageState.deliveryCost +
          (1 - payment.shippingState.confirmationStageState.cuponDiscount) * payment.shippingState.confirmationStageState.subtotal, 3),
      address: payment.selectedAddress,
      orderId: ObjectId(),
    );
  }
}
