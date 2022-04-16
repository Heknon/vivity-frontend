part of 'business_bloc.dart';

@immutable
abstract class BusinessState {
  const BusinessState();
}

class BusinessUnloaded extends BusinessState {}

class BusinessLoading extends BusinessUnloaded {}

class BusinessNoBusiness extends BusinessUnloaded {}

class BusinessLoaded extends BusinessState {
  final Business business;
  final List<Order> orders;
  final List<ItemModel> items;
  final List<ItemModel> orderItems;

//<editor-fold desc="Data Methods">

  const BusinessLoaded({
    required this.business,
    required this.orders,
    required this.items,
    required this.orderItems,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessLoaded &&
          runtimeType == other.runtimeType &&
          business == other.business &&
          orders == other.orders &&
          items == other.items &&
          orderItems == other.orderItems);

  @override
  int get hashCode => business.hashCode ^ orders.hashCode ^ items.hashCode ^ orderItems.hashCode;

  @override
  String toString() {
    return 'BusinessLoaded{' + ' business: $business,' + ' orders: $orders,' + ' items: $items,' + ' orderItems: $orderItems,' + '}';
  }

  BusinessLoaded copyWith({
    Business? business,
    List<Order>? orders,
    List<ItemModel>? items,
    List<ItemModel>? orderItems,
  }) {
    return BusinessLoaded(
      business: business ?? this.business,
      orders: orders ?? this.orders,
      items: items ?? this.items,
      orderItems: orderItems ?? this.orderItems,
    );
  }
//</editor-fold>
}
