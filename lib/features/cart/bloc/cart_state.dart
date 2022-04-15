part of './cart_bloc.dart';

abstract class CartState {
  const CartState();
}

class CartBlocked extends CartState {
}

class CartLoading extends CartBlocked {
}

class CartLoaded extends CartState {
  final List<CartItemModel> items;
  final ShippingMethod shippingMethod;

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
    required this.shippingMethod,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is CartLoaded &&
              runtimeType == other.runtimeType &&
              items == other.items &&
              shippingMethod == other.shippingMethod
          );


  @override
  int get hashCode =>
      items.hashCode ^
      shippingMethod.hashCode;


  @override
  String toString() {
    return 'CartStateLoaded{' +
        ' items: $items,' +
        ' shippingMethod: $shippingMethod,' +
        '}';
  }


  CartLoaded copyWith({
    List<CartItemModel>? items,
    ShippingMethod? shippingMethod,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      shippingMethod: shippingMethod ?? this.shippingMethod,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'items': this.items,
      'shippingMethod': this.shippingMethod,
    };
  }

  factory CartLoaded.fromMap(Map<String, dynamic> map) {
    return CartLoaded(
      items: map['items'] as List<CartItemModel>,
      shippingMethod: map['shippingMethod'] as ShippingMethod,
    );
  }


//</editor-fold>
}
