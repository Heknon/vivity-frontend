part of 'profile_bloc.dart';

@immutable
abstract class ProfileState {
  const ProfileState();
}

class ProfileUnloaded extends ProfileState {}

class ProfileLoading extends ProfileUnloaded {}

class ProfileLoaded extends ProfileState {
  final List<Address> addresses;
  final List<ItemModel> orderItems;
  final List<Order> orders;

//<editor-fold desc="Data Methods">

  const ProfileLoaded({
    required this.addresses,
    required this.orderItems,
    required this.orders,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileLoaded &&
          runtimeType == other.runtimeType &&
          addresses == other.addresses &&
          orderItems == other.orderItems &&
          orders == other.orders);

  @override
  int get hashCode => addresses.hashCode ^ orderItems.hashCode ^ orders.hashCode;

  @override
  String toString() {
    return 'ProfileLoaded{' + ' addresses: $addresses,' + ' orderItems: $orderItems,' + ' orders: $orders,' + '}';
  }

  ProfileLoaded copyWith({
    List<Address>? addresses,
    List<ItemModel>? orderItems,
    List<Order>? orders,
  }) {
    return ProfileLoaded(
      addresses: addresses ?? this.addresses,
      orderItems: orderItems ?? this.orderItems,
      orders: orders ?? this.orders,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addresses': this.addresses,
      'orderItems': this.orderItems,
      'orders': this.orders,
    };
  }

  factory ProfileLoaded.fromMap(Map<String, dynamic> map) {
    return ProfileLoaded(
      addresses: map['addresses'] as List<Address>,
      orderItems: map['orderItems'] as List<ItemModel>,
      orders: map['orders'] as List<Order>,
    );
  }

//</editor-fold>
}
