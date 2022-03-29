import 'package:vivity/features/user/models/order_item.dart';

class Order {
  final DateTime orderDate;
  final List<OrderItem> items;

  const Order({
    required this.orderDate,
    required this.items,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderDate: map['order_date'] as DateTime,
      items: (map['items'] as List<dynamic>).map((e) => OrderItem.fromMap(e)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'order_date': orderDate,
      'items': items.map((e) => e.toMap()).toList(),
    } as Map<String, dynamic>;
  }
}
