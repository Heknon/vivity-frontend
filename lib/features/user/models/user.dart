import 'dart:convert';
import 'dart:typed_data';

import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/business/models/order.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/user/models/user_options.dart';
import 'package:vivity/models/address.dart';

class User {
  final ObjectId id;
  final String name;
  final String email;
  final String phone;
  final Uint8List? profilePicture;
  final UserOptions userOptions;
  final List<Address> addresses;
  final List<ItemModel> likedItems;
  final List<CartItemModel> cart;
  final List<Order> orderHistory;

//<editor-fold desc="Data Methods">

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePicture,
    required this.userOptions,
    required this.addresses,
    required this.likedItems,
    required this.cart,
    required this.orderHistory,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          phone == other.phone &&
          profilePicture == other.profilePicture &&
          userOptions == other.userOptions &&
          addresses == other.addresses &&
          likedItems == other.likedItems &&
          cart == other.cart &&
          orderHistory == other.orderHistory);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      profilePicture.hashCode ^
      userOptions.hashCode ^
      addresses.hashCode ^
      likedItems.hashCode ^
      cart.hashCode ^
      orderHistory.hashCode;

  @override
  String toString() {
    return 'User{' +
        ' id: $id,' +
        ' name: $name,' +
        ' email: $email,' +
        ' phone: $phone,' +
        ' profilePicture: $profilePicture,' +
        ' userOptions: $userOptions,' +
        ' addresses: $addresses,' +
        ' likedItems: $likedItems,' +
        ' cart: $cart,' +
        ' orderHistory: $orderHistory,' +
        '}';
  }

  User copyWith({
    ObjectId? id,
    String? name,
    String? email,
    String? phone,
    Uint8List? profilePicture,
    UserOptions? userOptions,
    List<Address>? addresses,
    List<ItemModel>? likedItems,
    List<CartItemModel>? cart,
    List<Order>? orderHistory,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      userOptions: userOptions ?? this.userOptions,
      addresses: addresses ?? this.addresses,
      likedItems: likedItems ?? this.likedItems,
      cart: cart ?? this.cart,
      orderHistory: orderHistory ?? this.orderHistory,
    );
  }

  factory User.fromMap(Map<String, dynamic> map, Map<String, ItemModel>? cartItemIdMap) {
    List<dynamic> cartUnparsed = (map['cart'] as List<dynamic>);
    List<CartItemModel> cartItems = List.empty(growable: true);

    for (dynamic cartItemUnparsed in cartUnparsed) {
      if (cartItemIdMap == null || cartItemIdMap[cartItemUnparsed['item_id'] ?? ''] == null) continue;
      ItemModel? item = cartItemIdMap[cartItemUnparsed['item_id']];
      if (item == null) continue;
      cartItems.add(CartItemModel.fromMap(cartItemUnparsed, item));
    }

    return User(
      id: ObjectId.fromHexString(map['id']),
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      profilePicture: base64Decode(map['profile_picture']),
      userOptions: UserOptions.fromMap(map['user_options']),
      addresses: (map['addresses'] as List<dynamic>).map((e) => Address.fromMap(e)).toList(),
      likedItems: (map['liked_items'] as List<dynamic>).map((e) => ItemModel.fromMap(e)).toList(),
      cart: cartItems,
      orderHistory: (map['order_history'] as List<dynamic>).map((e) => Order.fromMap(e)).toList(),
    );
  }

//</editor-fold>
}
