part of 'payment_bloc.dart';

@immutable
abstract class PaymentState {
  const PaymentState();
}

class PaymentUnloaded extends PaymentState {}

class PaymentLoading extends PaymentUnloaded {}

class PaymentLoaded extends PaymentState {
  final ShippingLoaded shippingState;
  final Address? selectedAddress;

//<editor-fold desc="Data Methods">

  const PaymentLoaded({
    required this.shippingState,
    required this.selectedAddress,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentLoaded &&
          runtimeType == other.runtimeType &&
          shippingState == other.shippingState &&
          selectedAddress == other.selectedAddress);

  @override
  int get hashCode => shippingState.hashCode ^ selectedAddress.hashCode;

  @override
  String toString() {
    return 'PaymentLoaded{' + ' shippingState: $shippingState,' + ' selectedAddress: $selectedAddress,' + '}';
  }

  PaymentLoaded copyWith({
    ShippingLoaded? shippingState,
    Address? selectedAddress,
  }) {
    return PaymentLoaded(
      shippingState: shippingState ?? this.shippingState,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shippingState': this.shippingState,
      'selectedAddress': this.selectedAddress,
    };
  }

  factory PaymentLoaded.fromMap(Map<String, dynamic> map) {
    return PaymentLoaded(
      shippingState: map['shippingState'] as ShippingLoaded,
      selectedAddress: map['selectedAddress'] as Address,
    );
  }

//</editor-fold>
}

class PaymentProcessingPayment extends PaymentLoaded {
  PaymentProcessingPayment({
    required ShippingLoaded shippingState,
    required Address? selectedAddress,
  }) : super(shippingState: shippingState, selectedAddress: selectedAddress);
}

class PaymentSuccessPayment extends PaymentState {
  final Order order;
  final List<ItemModel> items;

  PaymentSuccessPayment(this.order, this.items);
}

class PaymentFailedPayment extends PaymentState {
  final String failedReason;

  PaymentFailedPayment(this.failedReason);
}
