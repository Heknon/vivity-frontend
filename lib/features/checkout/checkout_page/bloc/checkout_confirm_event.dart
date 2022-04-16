part of 'checkout_confirm_bloc.dart';

@immutable
abstract class CheckoutConfirmEvent {}

class CheckoutConfirmLoadEvent extends CheckoutConfirmEvent {
  final CartBloc cartBloc;

  CheckoutConfirmLoadEvent(this.cartBloc);
}

class CheckoutConfirmUpdateShippingEvent extends CheckoutConfirmEvent {
  final ShippingMethod shippingMethod;

  CheckoutConfirmUpdateShippingEvent(this.shippingMethod);
}

class CheckoutConfirmUpdateCuponEvent extends CheckoutConfirmEvent {
  final String cupon;

  CheckoutConfirmUpdateCuponEvent(this.cupon);
}
