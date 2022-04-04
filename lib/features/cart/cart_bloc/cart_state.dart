import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:vivity/features/cart/cart_service.dart';
import 'package:vivity/models/shipping_method.dart';
import 'package:vivity/widgets/quantity.dart';

import '../../item/models/item_model.dart';
import '../../user/bloc/user_bloc.dart';

class CartState {
  final List<CartItemModel> _items;
  ShippingMethod shippingMethod;

  late double priceTotal;
  late double shippingCost;

  List<CartItemModel> get items => _items;
  static final Map<int, QuantityController> _quantityControllers = {};

  CartState(this._items, this.shippingMethod) {
    int insertionId = 0;
    shippingCost = calculateShippingCost(shippingMethod);
    priceTotal = 0;

    for (CartItemModel item in _items) {
      item.insertionId = insertionId++;
      if (!_quantityControllers.containsKey(item.insertionId)) {
        _quantityControllers[item.insertionId] = QuantityController();
      }
      priceTotal += item.price * item.quantity;
    }
  }

  factory CartState.fromState(UserLoggedInState state) {
    return CartState(state.cart, ShippingMethod.delivery);
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

  CartState updateShipmentMethod(ShippingMethod shippingMethod) {
    this.shippingMethod = shippingMethod;
    shippingCost = calculateShippingCost(shippingMethod);
    return this;
  }

  double calculateShippingCost(ShippingMethod method) {
    // TODO: Connect to database - business
    if (method == ShippingMethod.pickup) {
      return 0;
    } else if (method == ShippingMethod.delivery) {
      double cost = 0; // 1.5 standard currency per item
      // TODO: Figure out how to support both USD and ILS. where to convert the currency? here?
      for (CartItemModel item in _items) {
        cost += item.quantity * 1.5;
      }

      return cost;
    }

    return -1;
  }

  Future<Response> saveToDatabase(String token, {BuildContext? context}) async {
    return await replaceDBCart(token, _items, context: context);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
      other is CartState &&
          runtimeType == other.runtimeType &&
          priceTotal == other.priceTotal &&
          shippingMethod == other.shippingMethod &&
          listEquals(_items, other._items);
  }

  @override
  int get hashCode => _items.hashCode ^ priceTotal.hashCode ^ shippingMethod.index.hashCode;

  CartState copyWith({
    List<CartItemModel>? items,
    ShippingMethod? shippingMethod,
  }) {
    return CartState(
      items ??
          _items.map(
            (e) {
              return e.copyWith(insertionId: e.insertionId);
            },
          ).toList(),
      shippingMethod ?? this.shippingMethod,
    );
  }

  QuantityController? getItemQuantityController(int insertionId) {
    return _quantityControllers[insertionId];
  }

  bool get cartIsEmpty => _items.isEmpty;

  @override
  String toString() {
    return 'CartState{_items: $_items, priceTotal: $priceTotal, shippingMethod: $shippingMethod}';
  }
}
