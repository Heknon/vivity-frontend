import 'dart:convert';

import 'package:http/http.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/services/api_service.dart';

ItemModel? getItemFromId(ObjectId businessId, ObjectId itemId) {
  return null;
}

Future<List<ItemModel>> getItemsFromIds(String token, List<ObjectId> ids) {
  return getItemsFromStringIds(token, ids.map((e) => e.hexString).toList());
}

Future<List<ItemModel>> getItemsFromStringIds(String token, List<String> ids) async {
  Response response = await sendGetRequest(subRoute: globalBusinessItemPath, token: token);
  List<dynamic> parsed = jsonDecode(response.body);

  return parsed.map((e) => ItemModel.fromDBMap(e)).toList();
}
