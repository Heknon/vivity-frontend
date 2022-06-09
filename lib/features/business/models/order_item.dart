import 'package:flutter/foundation.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/business/models/order.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/cart/models/modification_button_data_host.dart';
import 'package:vivity/features/item/models/modification_button.dart';

class OrderItem {
  final ObjectId? itemId;
  final double price;
  final int amount;
  final ObjectId? businessId;
  final OrderStatus status;
  final List<ModificationButtonDataHost> selectedModifiers;

  OrderItem({
    required this.itemId,
    required this.selectedModifiers,
    required this.price,
    required this.amount,
    required this.businessId,
    required this.status,
  });

  factory OrderItem.fromModifiers({
    required ObjectId itemId,
    required List<ModificationButton> modifiers,
    required Map<int, Iterable<int>> dataChosen,
    required double price,
    required int amount,
    required OrderStatus status,
    required ObjectId businessId,
  }) {
    List<ModificationButtonDataHost> chosenData = List.empty(growable: true);
    dataChosen.forEach(
      (key, value) => chosenData.add(ModificationButtonDataHost.fromModificationButton(modifiers[key], value)),
    );

    return OrderItem(itemId: itemId, selectedModifiers: chosenData, businessId: businessId, amount: amount, price: price, status: status);
  }

  factory OrderItem.fromCartItem(CartItemModel cartItem, {OrderStatus status = OrderStatus.processing}) {
    return OrderItem(
      itemId: cartItem.item.id,
      selectedModifiers: cartItem.modifiersChosen.toList(),
      price: cartItem.item.price,
      amount: cartItem.quantity,
      status: status,
      businessId: cartItem.item.businessId,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      itemId: ObjectId.fromHexString(map['item_id']),
      selectedModifiers: (map['selected_modifiers'] as List<dynamic>).map((e) => ModificationButtonDataHost.fromMap(e)).toList(),
      businessId: ObjectId.fromHexString(map['business_id']),
      amount: (map['amount'] as num).toInt(),
      price: (map['price'] as num).toDouble(),
      status: OrderStatus.values[(map['status'] as num).toInt()],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId?.hexString,
      'selected_modifiers': selectedModifiers.map((e) => e.toMap()).toList(),
      'amount': amount,
      'price': price,
      'business_id': businessId?.hexString,
      'status': status.index,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          runtimeType == other.runtimeType &&
          itemId == other.itemId &&
          listEquals(selectedModifiers, other.selectedModifiers) &&
          price == other.price &&
          amount == other.amount &&
          businessId == other.businessId &&
          status == other.status;

  @override
  int get hashCode => itemId.hashCode ^ selectedModifiers.hashCode ^ amount.hashCode ^ price.hashCode ^ businessId.hashCode ^ status.hashCode;

  @override
  String toString() {
    return 'OrderItem{itemId: $itemId, price: $price, amount: $amount, businessId: $businessId, selectedModifiers: $selectedModifiers, status: $status}';
  }
}
