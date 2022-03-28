import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/services/api_service.dart';
import 'package:latlong2/latlong.dart';

Future<ItemModel?> getItemFromId(String token, ObjectId itemId) async {
  return getItemsFromStringIds(token, [itemId.hexString]).then((value) => value[0]);
}

Future<List<ItemModel>> getItemsFromIds(String token, List<ObjectId> ids) {
  return getItemsFromStringIds(token, ids.map((e) => e.hexString).toList());
}

Future<List<ItemModel>> getItemsFromStringIds(String token, List<String> ids) async {
  Response response = await sendGetRequest(subRoute: globalBusinessItemRoute + "?item_ids=${ids.join(',')}", token: token);
  if (response.statusCode != 200) {
    throw Exception('Failed to get items. $response');
  }

  return (response.data as List<dynamic>).map((e) => ItemModel.fromDBMap(e)).toList();
}

Future<List<ItemModel>> searchByCoordinates(String token, LatLng position, double radius, {String query = "*", String category = "*"}) async {
  String searchQuery =
      "$exploreRoute?radius=$radius&radius_center_latitude=${position.latitude}&radius_center_longitude=${position.longitude}&query=$query&category=$category";

  Response response = await sendGetRequest(
    subRoute: searchQuery,
    token: token,
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to search. $response');
  }

  return (response.data as List<dynamic>).map((e) => ItemModel.fromDBMap(e)).toList();
}

Future<Iterable<ObjectId>?> addFavoriteItem(String token, ObjectId itemId) async {
  Response res = await sendPostRequest(subRoute: "$favoritesRoute?item_id=${itemId.hexString}", token: token);

  if (res.statusCode != 200) return null;

  return (res.data as List<dynamic>).map((e) => ObjectId.fromHexString(e));
}

Future<Iterable<ObjectId>?> removeFavoriteItem(String token, ObjectId itemId) async {
  Response res = await sendDeleteRequest(subRoute: "$favoritesRoute?item_id=${itemId.hexString}", token: token);

  if (res.statusCode != 200) return null;

  return (res.data as List<dynamic>).map((e) => ObjectId.fromHexString(e));
}
