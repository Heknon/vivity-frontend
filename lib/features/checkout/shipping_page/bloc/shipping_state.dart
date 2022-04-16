part of 'shipping_bloc.dart';

@immutable
abstract class ShippingState {
  const ShippingState();
}

class ShippingUnloaded extends ShippingState {}

class ShippingLoading extends ShippingUnloaded {}

class ShippingLoaded<T> extends ShippingState {
  final CheckoutConfirmLoaded confirmationStageState;
  final T addresses;

//<editor-fold desc="Data Methods">

  const ShippingLoaded({
    required this.confirmationStageState,
    required this.addresses,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShippingLoaded &&
          runtimeType == other.runtimeType &&
          confirmationStageState == other.confirmationStageState &&
          addresses == other.addresses);

  @override
  int get hashCode => confirmationStageState.hashCode ^ addresses.hashCode;

  @override
  String toString() {
    return 'ShippingLoaded{' + ' confirmationStageState: $confirmationStageState,' + ' addresses: $addresses,' + '}';
  }

  ShippingLoaded copyWith({
    CheckoutConfirmLoaded? confirmationStageState,
    T? addresses,
  }) {
    return ShippingLoaded(
      confirmationStageState: confirmationStageState ?? this.confirmationStageState,
      addresses: addresses ?? this.addresses,
    );
  }

//</editor-fold>
}

class ShippingPickupLoaded extends ShippingLoaded<Map<CartItemModel, Address>> {
  ShippingPickupLoaded({
    required CheckoutConfirmLoaded confirmationStageState,
    required Map<CartItemModel, Address> addresses,
  }) : super(confirmationStageState: confirmationStageState, addresses: addresses);
}

class ShippingDeliveryLoaded extends ShippingLoaded<List<Address>> {
  ShippingDeliveryLoaded({
    required CheckoutConfirmLoaded confirmationStageState,
    required List<Address> addresses,
  }) : super(confirmationStageState: confirmationStageState, addresses: addresses);
}
