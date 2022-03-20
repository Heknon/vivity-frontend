part of 'checkout_bloc.dart';

@immutable
abstract class CheckoutEvent {}

/// Event called when the checkout state is initialized after confirmation stage in order to keep cart in sync
class CheckoutInitializeEvent extends CheckoutEvent {
  final List<CartItemModel> items;
  final ShippingMethod shippingMethod;
  final String? cuponCode;

  CheckoutInitializeEvent({required this.items, required this.shippingMethod, required this.cuponCode});
}

class CheckoutApplyShippingEvent extends CheckoutEvent {
  final Address? address;

  CheckoutApplyShippingEvent({required this.address});
}

class CheckoutApplyCuponEvent extends CheckoutEvent {
  final String cuponCode;

  CheckoutApplyCuponEvent({required this.cuponCode});
}

class CheckoutApplyShippingMethodEvent extends CheckoutEvent {
  final ShippingMethod shippingMethod;

  CheckoutApplyShippingMethodEvent({required this.shippingMethod});
}

class CheckoutSelectPaymentEvent extends CheckoutEvent {
  final PaymentMethod? paymentMethod;

  CheckoutSelectPaymentEvent({
    required this.paymentMethod,
  });
}
