part of 'checkout_bloc.dart';

@immutable
class CheckoutState {
  final List<CartItemModel> items;
  final ShippingMethod shippingMethod;
  final String? cuponCode;
  final PaymentMethod? paymentMethod;

  late Address? shippingAddress;

  late double subtotal;
  late double shippingCost;
  late double cuponDiscount;
  late double total;

  CheckoutState({required this.items, required this.shippingMethod, required this.cuponCode, this.shippingAddress, this.paymentMethod}) {
    double sub = 0;

    for (CartItemModel element in items) {
      sub += element.price * element.quantity;
    }

    subtotal = sub;

    shippingCost = shippingMethod == ShippingMethod.pickup ? 0 : getShippingCost(items);
    cuponDiscount = getCuponDiscount(cuponCode, items);
    total = subtotal + shippingCost - cuponDiscount;
  }

  Future<bool> processPayment() async {
    return Future.value(true);
  }

  Future<bool> validatePaymentMethod() async {
    return Future.value(true);
  }
}
