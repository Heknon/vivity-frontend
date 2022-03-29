import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:path_provider/path_provider.dart';
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

Future<Map<String, File>?> getCachedItemImages(String token, Iterable<ItemModel> items, {bool fetchIfNotFound = true}) async {
  Map<String, Set<String>> nonExsistentImageIds = {};
  String path = (await getTemporaryDirectory()).path + '/items';
  Map<String, File> result = {};

  for (ItemModel item in items) {
    nonExsistentImageIds[item.id.hexString] = Set();

    for (String imageId in item.images) {
      File file = File('$path/item_${item.id.hexString}_$imageId.png');
      if (!(await file.exists())) {
        nonExsistentImageIds[item.id.hexString]!.add(imageId);
      } else {
        result[imageId] = file;
      }
    }

    if (nonExsistentImageIds[item.id.hexString]!.isEmpty) {
      nonExsistentImageIds.remove(item.id.hexString);
    }
  }

  if (fetchIfNotFound && nonExsistentImageIds.isNotEmpty) {
    Map<String, File>? notFoundResult = await getItemImagesBase(token, nonExsistentImageIds);
    for (var entry in notFoundResult?.entries ?? {}.entries) {
      result[entry.key] = entry.value;
    }
  }

  return result;
}

Future<Map<String, File>?> getItemImages(String token, List<ItemModel> items) async {
  return getItemImagesBase(token, items.asMap().map((key, value) => MapEntry(value.id.hexString, value.images.toSet())));
}

Future<Map<String, File>?> getItemImagesBase(String token, Map<String, Set<String>> ids) async {
  String joinedString = "";
  Map<String, String> imageIdToItemId = {};
  for (var entry in ids.entries) {
    for (String imageId in entry.value) {
      joinedString += imageId + ',';
      imageIdToItemId[imageId] = entry.key;
    }
  }

  print("?folder_name=items/&image_ids=$joinedString");
  Response res = await sendGetRequest(subRoute: multiImageRoute + "?folder_name=items/&image_ids=$joinedString", token: token);
  if (res.statusCode != 200) return null;

  Map<String, dynamic>? resData = res.data as Map<String, dynamic>;
  Map<String, File> result = {};

  Directory tempDir = Directory("${(await getTemporaryDirectory()).path}/items");
  if (!(await tempDir.exists())) {
    await tempDir.create();
  }

  for (var entry in resData.entries) {
    String b64 = entry.value as String;
    Uint8List data = base64Decode(b64);
    result[entry.key] = await File('${tempDir.path}/item_${imageIdToItemId[entry.key]}_${entry.key}.png').writeAsBytes(data);
  }

  return result;
}
