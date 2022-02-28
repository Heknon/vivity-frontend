import 'package:flutter/foundation.dart';
import 'package:vivity/widgets/quantity.dart';

import '../../item/models/item_model.dart';

class CartState {
  final List<CartItemModel> _items;
  double priceTotal = 0;

  List<CartItemModel> get items => _items;
  static final Map<int, QuantityController> _quantityControllers = {};

  CartState(this._items) {
    int insertionId = 0;
    for (CartItemModel item in _items) {
      item.insertionId = insertionId++;
      if (!_quantityControllers.containsKey(item.insertionId)) {
        _quantityControllers[item.insertionId] = QuantityController();
      }
      priceTotal += item.price * item.quantity;
    }
  }

  CartState addItem(CartItemModel item) {
    if (item.quantity <= 0) {
      return this;
    }

    Iterable<CartItemModel> cartedItems = _items.where((element) => element.looseEquals(item));
    if (cartedItems.isNotEmpty) {
      CartItemModel cartedItem = cartedItems.first;
      QuantityController itemQController = getItemQuantityController(cartedItem.insertionId)!;
      int originalQuantity = cartedItem.quantity;
      cartedItem.quantity += item.quantity;
      itemQController.updateCurrentQuantity(cartedItem.quantity);
      cartedItem.quantity = itemQController.quantity;
      priceTotal += item.price * (cartedItem.quantity - originalQuantity);
      return this;
    }

    _items.add(item);
    priceTotal += item.price * item.quantity;
    return this;
  }

  CartState removeItem(int insertionId) {
    _items.removeWhere((element) {
      if (element.insertionId == insertionId) {
        priceTotal -= element.price * element.quantity;
        element.quantity = 0;
        return true;
      }

      return false;
    });

    _quantityControllers.remove(insertionId);

    return this;
  }

  CartState decrementQuantity(int insertionId) {
    CartItemModel item = getItem(insertionId);
    item.quantity--;
    priceTotal -= item.price;

    if (item.quantity <= 0) {
      removeItem(insertionId);
    }

    return this;
  }

  CartState incrementQuantity(int insertionId) {
    CartItemModel item = getItem(insertionId);
    item.quantity++;
    priceTotal += item.price;

    return this;
  }

  CartItemModel getItem(int insertionId) {
    return _items.where((element) {
      return element.insertionId == insertionId;
    }).first;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartState && runtimeType == other.runtimeType && listEquals(_items, other._items) && priceTotal == other.priceTotal;

  @override
  int get hashCode => _items.hashCode ^ priceTotal.hashCode;

  factory CartState.fromMap(Map<String, dynamic> map) {
    return CartState(
      (map["items"] as List<dynamic>).map((e) => CartItemModel.fromMap(e)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'items': _items.map((e) => e.toMap()).toList(),
    } as Map<String, dynamic>;
  }

  CartState copyWith({
    List<CartItemModel>? items,
    double? priceTotal,
  }) {
    return CartState(
      items ??
          _items.map(
            (e) {
              return e.copyWith(insertionId: e.insertionId);
            },
          ).toList(),
    );
  }

  QuantityController? getItemQuantityController(int insertionId) {
    return _quantityControllers[insertionId];
  }

  bool get cartIsEmpty => _items.isEmpty;

  @override
  String toString() {
    return 'CartState{_items: $_items, priceTotal: $priceTotal}';
  }
}
