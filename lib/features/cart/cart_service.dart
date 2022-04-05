import 'dart:convert';

import 'package:charset/charset.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/item/models/item_model.dart';

import '../../services/api_service.dart';
import '../user/bloc/user_bloc.dart';
import 'cart_bloc/cart_bloc.dart';

Future<Response> replaceDBCart(String token, List<CartItemModel> cartItems, {BuildContext? context}) async {
  List<Map<String, dynamic>> replacement = convertToDBCartItems(cartItems);
  return await sendPostRequest(subRoute: cartRoute, token: token, data: replacement, context: context);
}

Future<Map<String, ItemModel>> getFullItemModelCartData(String token) async {
  Response res = await sendGetRequest(subRoute: cartRoute, token: token);
  if (res.statusCode != 200) {
    throw res;
  }

  Map<String, ItemModel> result = {};

  for (var element in res.data) {
    ItemModel item = ItemModel.fromMap(element);
    result[item.id.hexString] = item;
  }

  return result;
}

Future<List<CartItemModel>> getCartFromDBCart(String token, List<dynamic> dbCart) async {
  Map<String, ItemModel> items = await getFullItemModelCartData(token);
  List<CartItemModel> result = List.empty(growable: true);

  for (var element in dbCart) {
    ItemModel? correspondingItem = items[element["item_id"]];
    if (correspondingItem == null) continue;

    result.add(CartItemModel(
      previewImage: correspondingItem.images[correspondingItem.previewImageIndex],
      title: correspondingItem.itemStoreFormat.title,
      modifiersChosen: (element["modifiers_chosen"] as List<dynamic>).map((e) => ModificationButtonDataHost.fromMap(e)).toList(),
      quantity: element["amount"],
      price: correspondingItem.price,
      item: correspondingItem,
    ));
  }

  return result;
}

Map<String, dynamic> convertToDBCartItem(CartItemModel cartItem) {
  return {
    "item_id": cartItem.item?.id.hexString,
    "amount": cartItem.quantity,
    "modifiers_chosen": cartItem.modifiersChosen.map((e) => e.toMap()).toList(),
  };
}

List<Map<String, dynamic>> convertToDBCartItems(Iterable<CartItemModel> cartItems) {
  return cartItems.map((e) => convertToDBCartItem(e)).toList();
}

void saveCart(BuildContext context) {
  UserState userState = context.read<UserBloc>().state;
  if (userState is! UserLoggedInState) return;
  List<CartItemModel> cartItems = context.read<CartBloc>().state.items;
  if (listEquals(cartItems, userState.cart)) return;

  replaceDBCart(userState.token, cartItems, context: context);
}
