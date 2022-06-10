import 'package:flutter/foundation.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/business/models/order_item.dart';
import 'package:vivity/models/shipping_method.dart';

import '../../address/models/address.dart';

class Order {
  final ObjectId orderId;
  final DateTime orderDate;
  final double subtotal;
  final double shippingCost;
  final double cuponDiscount;
  final double total;
  final Address? address;
  final ShippingMethod shippingMethod;
  final List<OrderItem> items;

  const Order({
    required this.orderDate,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.cuponDiscount,
    required this.total,
    required this.address,
    required this.orderId,
    required this.shippingMethod,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: ObjectId.fromHexString(map['_id']),
      orderDate: DateTime.fromMillisecondsSinceEpoch((map['order_date'] as num).toInt() * 1000),
      items: (map['items'] as List<dynamic>).map((e) => OrderItem.fromMap(e)).toList(),
      address: map['shipping_address'] != null ? Address.fromMap(map['shipping_address']) : null,
      cuponDiscount: (map['cupon_discount'] as num).toDouble(),
      shippingCost: (map['shipping_cost'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      shippingMethod: ShippingMethod.values[(map['shipping_method'] as num).toInt()],
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'order_date': orderDate.millisecondsSinceEpoch,
      'items': items.map((e) => e.toMap()).toList(),
      'address': address?.toMap(),
      'cupon_discount': cuponDiscount,
      'shipping_cost': shippingCost,
      'subtotal': subtotal,
      'total': total,
      '_id': orderId.hexString,
      'shipping_method': shippingMethod.index,
    } as Map<String, dynamic>;
  }

  Order copyWith({
    DateTime? orderDate,
    double? subtotal,
    double? shippingCost,
    double? cuponDiscount,
    double? total,
    Address? address,
    List<OrderItem>? items,
    OrderStatus? status,
    ObjectId? orderId,
    ShippingMethod? shippingMethod,
  }) {
    if ((orderDate == null || identical(orderDate, this.orderDate)) &&
        (subtotal == null || identical(subtotal, this.subtotal)) &&
        (shippingCost == null || identical(shippingCost, this.shippingCost)) &&
        (cuponDiscount == null || identical(cuponDiscount, this.cuponDiscount)) &&
        (total == null || identical(total, this.total)) &&
        (address == null || identical(address, this.address)) &&
        (items == null || identical(items, this.items))) {
      return this;
    }

    return Order(
      orderDate: orderDate ?? this.orderDate,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      cuponDiscount: cuponDiscount ?? this.cuponDiscount,
      total: total ?? this.total,
      address: address ?? this.address,
      items: items ?? this.items,
      orderId: orderId ?? this.orderId,
      shippingMethod: shippingMethod ?? this.shippingMethod,
    );
  }

  @override
  String toString() {
    return 'Order{orderDate: $orderDate, subtotal: $subtotal, shippingCost: $shippingCost, cuponDiscount: $cuponDiscount, total: $total, address: $address, items: $items}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          orderId == other.orderId &&
          runtimeType == other.runtimeType &&
          orderDate == other.orderDate &&
          subtotal == other.subtotal &&
          shippingCost == other.shippingCost &&
          cuponDiscount == other.cuponDiscount &&
          total == other.total &&
          address == other.address &&
          shippingMethod == other.shippingMethod &&
          listEquals(items, other.items);

  @override
  int get hashCode =>
      orderDate.hashCode ^
      subtotal.hashCode ^
      shippingCost.hashCode ^
      cuponDiscount.hashCode ^
      total.hashCode ^
      address.hashCode ^
      items.hashCode ^
      orderId.hashCode ^
      shippingMethod.hashCode;
}

enum OrderStatus { processing, processed, shipping, shipped, readyForPickup, complete }

extension EnumHelper on Enum {
  String toTitle() {
    String name = this.name;
    String result = "";

    for (int i = 0; i < name.length; i++) {
      String c = name[i];
      if (i == 0) {
        result += c.toUpperCase();
        continue;
      }

      String? nextC = i + 1 < name.length ? name[i + 1] : null;
      if (nextC != null && nextC.toUpperCase() == nextC) {
        result += '$c ';
      }

      if (c.toUpperCase() == c) {
        result += c.toLowerCase();
      } else {
        result += c;
      }
    }

    return result;
  }
}

extension OrderStatusHelper on OrderStatus {
  String getName() {
    switch (this) {
      case OrderStatus.processing:
        return "Processing";
      case OrderStatus.processed:
        return "Processed";
      case OrderStatus.shipping:
        return "Shipping";
      case OrderStatus.shipped:
        return "Shipped";
      case OrderStatus.readyForPickup:
        return "Ready for pickup";
      case OrderStatus.complete:
        return "Complete";
      default:
        return "wat";
    }
  }
}
