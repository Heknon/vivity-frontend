part of './cart_bloc.dart';

abstract class CartState {
  const CartState();
}

class CartBlocked extends CartState {}

class CartLoading extends CartBlocked {}

class CartLoaded extends CartState {
  final List<CartItemModel> items;
  final Map<int, QuantityController> quantityControllersHash;

  double get total {
    double sum = 0;
    for (CartItemModel item in items) {
      sum += item.item.price * item.quantity;
    }
    return sum;
  }

//<editor-fold desc="Data Methods">

  CartLoaded({
    required this.items,
    required this.quantityControllersHash,
  }) {
    for (CartItemModel item in items) {
      if (quantityControllersHash.containsKey(item.hashCode)) continue;
      quantityControllersHash[item.hashCode] = new QuantityController(quantity: item.quantity);
    }
  }

  QuantityController? getQuantityController(CartItemModel item) {
    return quantityControllersHash[item.hashCode];
  }

  @override
  bool operator ==(Object other) => identical(this, other) || (other is CartLoaded && runtimeType == other.runtimeType && items == other.items);

  @override
  int get hashCode => items.hashCode;

  @override
  String toString() {
    return 'CartStateLoaded{' + ' items: $items,' + '}';
  }

  CartLoaded copyWith({
    List<CartItemModel>? items,
    Map<int, QuantityController>? quantityControllersHash,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      quantityControllersHash: quantityControllersHash ?? this.quantityControllersHash,
    );
  }

//</editor-fold>
}
