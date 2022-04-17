part of 'shipping_bloc.dart';

@immutable
abstract class ShippingEvent {}

class ShippingLoadEvent extends ShippingEvent {
  final CheckoutConfirmBloc confirmationStageBloc;

  ShippingLoadEvent(this.confirmationStageBloc);
}

class ShippingReplaceAddressesEvent extends ShippingEvent {
  final List<Address> addresses;

  ShippingReplaceAddressesEvent(this.addresses);
}

class ShippingConfirmStageStateUpdateEvent extends ShippingEvent {
  final CheckoutConfirmState state;

  ShippingConfirmStageStateUpdateEvent(this.state);
}
