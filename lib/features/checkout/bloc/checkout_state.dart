part of 'checkout_bloc.dart';

@immutable
abstract class CheckoutState {
  Future<bool> init();
}

class CheckoutInitial extends CheckoutState {
  @override
  Future<bool> init() async => true;
}

class CheckoutLoadingState extends CheckoutState {
  @override
  Future<bool> init() async => true;
}

class CheckoutStateConfirmationStage extends CheckoutState {
  final List<CartItemModel> items;

  final ShippingMethod shippingMethod;
  final String? cuponCode;

  // final PaymentMethod? paymentMethod;

  // late Address? shippingAddress;

  late double subtotal;
  late double shippingCost;
  late double cuponDiscount;
  late double total;

  CheckoutStateConfirmationStage({required this.items, required this.cuponCode, required this.shippingMethod});

  @override
  Future<bool> init() async {
    double sub = 0;

    for (CartItemModel element in items) {
      sub += element.price * element.quantity;
    }

    subtotal = sub;

    shippingCost = shippingMethod == ShippingMethod.pickup ? 0 : getEstimatedShippingCost(items);
    cuponDiscount = getCuponDiscount(cuponCode, items);
    total = subtotal + shippingCost - cuponDiscount;

    return true;
  }

  Future<bool> verifySubtotal() {
    return Future.value(true);
  }
}

class CheckoutStateShippingStage extends CheckoutStateConfirmationStage {
  final Address? shippingAddress;
  late double shippingCost;

  CheckoutStateShippingStage({
    required this.shippingAddress,
    required List<CartItemModel> items,
    required String? cuponCode,
    required ShippingMethod shippingMethod,
  }) : super(
          items: items,
          cuponCode: cuponCode,
          shippingMethod: shippingMethod,
        );

  @override
  Future<bool> init() async {
    if (shippingAddress == null) {
      shippingCost = 0;
      return true;
    }

    shippingCost = await getShippingCost(items, shippingAddress!);
    return true;
  }
}

class CheckoutStatePaymentStage extends CheckoutStateShippingStage {
  PaymentMethod? paymentMethod;

  CheckoutStatePaymentStage({
    required this.paymentMethod,
    required Address? shippingAddress,
    required List<CartItemModel> items,
    required String? cuponCode,
    required ShippingMethod shippingMethod,
  }) : super(
          shippingAddress: shippingAddress,
          items: items,
          cuponCode: cuponCode,
          shippingMethod: shippingMethod,
        );

  @override
  Future<bool> init() async => true;

  Future<bool> processPayment() async {
    return Future.value(true);
  }

  Future<bool> validatePaymentMethod() async {
    return Future.value(true);
  }
}
