import 'dart:convert';

import 'package:http/http.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/services/api_service.dart';
import 'package:latlong2/latlong.dart';

ItemModel? getItemFromId(ObjectId businessId, ObjectId itemId) {
  return null;
}

Future<List<ItemModel>> getItemsFromIds(String token, List<ObjectId> ids) {
  return getItemsFromStringIds(token, ids.map((e) => e.hexString).toList());
}

Future<List<ItemModel>> getItemsFromStringIds(String token, List<String> ids) async {
  Response response = await sendGetRequest(subRoute: globalBusinessItemRoute, token: token);
  if (response.statusCode != 200) {
    throw Exception('Failed to get items. $response');
  }

  List<dynamic> parsed = jsonDecode(response.body);

  return parsed.map((e) => ItemModel.fromDBMap(e)).toList();
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

  List<dynamic> parsed = jsonDecode(response.body);

  return parsed.map((e) => ItemModel.fromDBMap(e)).toList();
}
