import '../../models/address.dart';
import '../item/models/item_model.dart';
import 'bloc/checkout_bloc.dart';

double getEstimatedShippingCost(List<CartItemModel> items) {
  double p = 0;

  for (CartItemModel element in items) {
    p += element.quantity * 1.25;
  }

  return p;
}

Future<double> getShippingCost(List<CartItemModel> items, Address address) async {
  return 0;
}

double getCuponDiscount(String? cuponCode, List<CartItemModel> items) {
  if (cuponCode == null) return 0;

  double p = 0;

  for (CartItemModel element in items) {
    p += element.quantity * element.price;
  }

  return p * (1 - 0.75);
}

Future<bool> sendPaymentRequest(List<CartItemModel> items) {
  return Future.value(true);
}

void navigateToCorrectCheckoutPage(CheckoutState state) {
  switch (state.runtimeType) {
    case CheckoutStateConfirmationStage:
      print("1");
      break;
    case CheckoutStateShippingStage:
      print("2");
      break;
    case CheckoutStatePaymentStage:
      print("3");
      break;
  }
}
