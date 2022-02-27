import 'package:flutter/foundation.dart';

import '../../item/models/item_model.dart';

class CartState {
  final List<CartItemModel> _items;
  double priceTotal = 0;

  List<CartItemModel> get items => _items;

  CartState(this._items) {
    int insertionId = 0;
    for (CartItemModel item in _items) {
      item.insertionId = insertionId++;
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
      cartedItem.quantity += item.quantity;
      priceTotal += item.price * item.quantity;
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
    return CartState((map["items"] as List<dynamic>).map((e) => CartItemModel.fromMap(e)).toList());
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
          _items.map((e) {
            return e.copyWith(insertionId: e.insertionId);
          }).toList()
    );
  }

  bool get cartIsEmpty => _items.isEmpty;
}
