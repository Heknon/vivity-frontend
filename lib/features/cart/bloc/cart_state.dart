part of './cart_bloc.dart';

abstract class CartState {
  const CartState();
}

class CartBlocked extends CartState {}

class CartLoading extends CartBlocked {}

class CartLoaded extends CartState {
  final List<CartItemModel> items;

  double get total {
    double sum = 0;
    for (CartItemModel item in items) {
      sum += item.item.price * item.quantity;
    }
    return sum;
  }

//<editor-fold desc="Data Methods">

  const CartLoaded({
    required this.items,
  });

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
    ShippingMethod? shippingMethod,
  }) {
    return CartLoaded(
      items: items ?? this.items,
    );
  }

//</editor-fold>
}
