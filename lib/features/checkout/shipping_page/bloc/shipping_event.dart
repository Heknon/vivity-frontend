part of 'shipping_bloc.dart';

@immutable
abstract class ShippingEvent {}

class ShippingLoadEvent extends ShippingEvent {
  final CheckoutConfirmBloc confirmationStageBloc;

  ShippingLoadEvent(this.confirmationStageBloc);
}

class ShippingAddAddressEvent extends ShippingEvent {}

class ShippingRemoveAddressEvent extends ShippingEvent {}
