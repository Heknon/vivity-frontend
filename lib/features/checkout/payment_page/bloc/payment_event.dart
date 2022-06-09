part of 'payment_bloc.dart';

@immutable
abstract class PaymentEvent {}

class PaymentLoadEvent extends PaymentEvent {
  final ShippingBloc shippingBloc;
  final Address? address;

  PaymentLoadEvent(this.shippingBloc, this.address);
}

class PaymentPayEvent extends PaymentEvent {
  final String cardNumber;
  final String cvv;
  final String name;
  final int month;
  final int year;
  final double total;

  PaymentPayEvent({
    required this.cardNumber,
    required this.cvv,
    required this.name,
    required this.month,
    required this.year,
    required this.total,
  });
}

class PaymentShippingStateUpdate extends PaymentEvent {
  final ShippingState state;

  PaymentShippingStateUpdate(this.state);
}
