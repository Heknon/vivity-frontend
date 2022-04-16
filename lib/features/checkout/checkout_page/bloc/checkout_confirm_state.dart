part of 'checkout_confirm_bloc.dart';

@immutable
abstract class CheckoutConfirmState {
  const CheckoutConfirmState();
}

class CheckoutConfirmUnloaded extends CheckoutConfirmState {}

class CheckoutConfirmLoading extends CheckoutConfirmUnloaded {}

class CheckoutConfirmLoaded extends CheckoutConfirmState {
  final List<CartItemModel> items;
  final ShippingMethod shippingMethod;
  final String cupon;
  final double deliveryCost;
  final double cuponDiscount;
  final double subtotal;

  double get total => subtotal + deliveryCost - cuponDiscount;

//<editor-fold desc="Data Methods">

  const CheckoutConfirmLoaded({
    required this.items,
    required this.shippingMethod,
    required this.cupon,
    required this.deliveryCost,
    required this.cuponDiscount,
    required this.subtotal,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckoutConfirmLoaded &&
          runtimeType == other.runtimeType &&
          items == other.items &&
          shippingMethod == other.shippingMethod &&
          cupon == other.cupon &&
          deliveryCost == other.deliveryCost &&
          cuponDiscount == other.cuponDiscount &&
          subtotal == other.subtotal &&
          total == other.total);

  @override
  int get hashCode =>
      items.hashCode ^ shippingMethod.hashCode ^ cupon.hashCode ^ deliveryCost.hashCode ^ cuponDiscount.hashCode ^ subtotal.hashCode ^ total.hashCode;

  @override
  String toString() {
    return 'CheckoutConfirmLoaded{items: $items, shippingMethod: $shippingMethod, cupon: $cupon, deliveryCost: $deliveryCost, cuponDiscount: $cuponDiscount, subtotal: $subtotal}';
  }

  CheckoutConfirmLoaded copyWith({
    List<CartItemModel>? items,
    ShippingMethod? shippingMethod,
    String? cupon,
    double? deliveryCost,
    double? cuponDiscount,
    double? subtotal,
  }) {
    return CheckoutConfirmLoaded(
      items: items ?? this.items,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      cupon: cupon ?? this.cupon,
      subtotal: subtotal ?? this.subtotal,
      cuponDiscount: cuponDiscount ?? this.cuponDiscount,
      deliveryCost: deliveryCost ?? this.deliveryCost,
    );
  }

//</editor-fold>
}
