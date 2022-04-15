import 'dart:typed_data';

import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/models/user_options.dart';
import 'package:vivity/features/address/models/address.dart';
import 'package:vivity/features/business/models/order.dart';

class BusinessUser extends User {
  final ObjectId businessId;

  BusinessUser({
    required ObjectId id,
    required this.businessId,
    required String name,
    required String email,
    required String phone,
    required Uint8List? profilePicture,
    required UserOptions userOptions,
    required List<Address> addresses,
    required List<ItemModel> likedItems,
    required List<CartItemModel> cart,
    required List<Order> orderHistory,
    required bool isAdmin,
  }) : super(
          id: id,
          name: name,
          email: email,
          phone: phone,
          profilePicture: profilePicture,
          userOptions: userOptions,
          addresses: addresses,
          likedItems: likedItems,
          cart: cart,
          orderHistory: orderHistory,
          isAdmin: isAdmin,
        );

  Map<String, dynamic> toMap() {
    return {
      'businessId': this.businessId,
    };
  }

  factory BusinessUser.fromMap(Map<String, dynamic> map, Map<String, ItemModel>? cartItemIdMap) {
    User user = User.fromMap(map, cartItemIdMap);

    return BusinessUser(
      id: user.id,
      businessId: ObjectId.fromHexString(map['business_id']),
      phone: user.phone,
      email: user.email,
      userOptions: user.userOptions,
      name: user.name,
      orderHistory: user.orderHistory,
      profilePicture: user.profilePicture,
      addresses: user.addresses,
      likedItems: user.likedItems,
      cart: user.cart,
      isAdmin: user.isAdmin,
    );
  }
}
