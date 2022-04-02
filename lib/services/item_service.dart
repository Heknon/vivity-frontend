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
  if (response.statusCode! > 300) {
    throw Exception('Failed to get items. $response');
  }

  return (response.data as List<dynamic>).map((e) => ItemModel.fromMap(e)).toList();
}

Future<ItemModel> createItem(
  String token, {
  required String title,
  required String subtitle,
  required String brand,
  required String category,
  required List<String> tags,
  required double price,
}) async {
  Response response = await sendPostRequest(subRoute: itemRoute, token: token, data: {
    'title': title,
    'subtitle': subtitle,
    'brand': brand,
    'category': category,
    'tags': tags,
    'price': price,
  });
  if (response.statusCode! > 300) {
    throw Exception('Failed to get items. $response');
  }

  return ItemModel.fromMap(response.data);
}

Future<ItemModel> updateItem(String token, String itemId, {
  String? title,
  String? subtitle,
  String? description,
  double? price,
  String? brand,
  String? category,
  List<String>? addTags,
  List<String>? removeTags,
  List<String>? tags,
  int? stock,
  List<ModificationButton>? modificationButtons,
}) async {
  Map<String, dynamic> updateBody = {
    "title": title,
    "subtitle": subtitle,
    "description": description,
    "price": price,
    "brand": brand,
    "category": category,
    "add_tags": addTags,
    "remove_tags": removeTags,
    "stock": stock,
    "tags": tags,
    "modification_buttons": modificationButtons?.map((e) => e.toMap()).toList(),
  };
  Response response = await sendPatchRequest(subRoute: itemUpdateRoute.replaceFirst("{item_id}", itemId), token: token, data: updateBody);
  if (response.statusCode! > 300) {
    throw Exception('Failed to update item. $response');
  }

  return ItemModel.fromMap(response.data);
}

Future<ItemModel> swapImageOfItem(String token, String itemId, File image, int index) async {
  Response response = await sendPostRequestUploadFile(subRoute: itemImageRoute.replaceFirst("{item_id}", itemId) + "?index=$index", token: token, file: image);

  if (response.statusCode! > 300) {
    throw Exception('Failed to swap item image. $response');
  }

  return ItemModel.fromMap(response.data);
}

Future<ItemModel> removeImageFromItem(String token, String itemId, int index) async {
  Response response = await sendDeleteRequest(subRoute: itemImageRoute.replaceFirst("{item_id}", itemId) + "?index=$index", token: token);

  if (response.statusCode! > 300) {
    throw Exception('Failed to delete image. $response');
  }

  return ItemModel.fromMap(response.data);
}

Future<ItemModel> updateItemStock(String token, String id, int stock) async {
  Response response = await sendPostRequest(subRoute: businessViewMetricRoute.replaceFirst("{item_id}", id) + "?stock=$stock", token: token);
  if (response.statusCode! > 300) {
    throw Exception('Failed to update item stock. $response');
  }

  return ItemModel.fromMap(response.data);
}

Future<int> addItemView(String token, String itemId) async {
  Response response = await sendPostRequest(subRoute: itemViewMetricRoute.replaceFirst("{item_id}", itemId), token: token);
  if (response.statusCode! > 300) {
    throw Exception('Failed to update view count. $response');
  }

  return response.data;
}

Future<List<ItemModel>> searchByCoordinates(String token, LatLng position, double radius, {String query = "*", String category = "*"}) async {
  String searchQuery =
      "$exploreRoute?radius=$radius&radius_center_latitude=${position.latitude}&radius_center_longitude=${position.longitude}&query=$query&category=$category";

  Response response = await sendGetRequest(
    subRoute: searchQuery,
    token: token,
  );

  if (response.statusCode! > 300) {
    throw Exception('Failed to search. $response');
  }

  return (response.data as List<dynamic>).map((e) => ItemModel.fromMap(e)).toList();
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
