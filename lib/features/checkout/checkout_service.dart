import '../item/models/item_model.dart';

double getShippingCost(List<CartItemModel> items) {
  double p = 0;

  for (CartItemModel element in items) {
    p += element.quantity * 1.25;
  }

  return p;
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
