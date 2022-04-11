import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/constants/api_path.dart' as api_route;
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/services/service_provider.dart';

class ItemService extends ServiceProvider {
  final AuthenticationRepository _authRepository = AuthenticationRepository();

  static final ItemService _itemService = ItemService._();

  static const String itemStockRoute = "/{item_id}/stock";
  static const String itemImageRoute = "/{item_id}/image";
  static const String itemRoute = "/{item_id}";
  static const String itemReviewRoute = "/{item_id}/review";

  ItemService._() : super(baseRoute: api_route.itemRoute);

  factory ItemService() => _itemService;

  Future<AsyncSnapshot<List<ItemModel>>> getItems({required List<String> itemIds, required bool getItemImages}) async {
    AsyncSnapshot<Response> snapshot = await get(queryParameters: {
      "item_ids": itemIds,
      'include_images': getItemImages,
    });

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withError(ConnectionState.done, response);
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      (response.data as List<dynamic>).map((e) => ItemModel.fromMap(e, hasImages: getItemImages)).toList(),
    );
  }

  Future<AsyncSnapshot<ItemModel>> createItem({
    required String title,
    required String subtitle,
    required String brand,
    required String category,
    required List<String> tags,
    required double price,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    AsyncSnapshot<Response> snapshot = await post(token: accessToken, data: {
      'title': title,
      'subtitle': subtitle,
      'brand': brand,
      'category': category,
      'tags': tags,
      'price': price,
    });

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withError(ConnectionState.done, response);
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      ItemModel.fromMap(response.data),
    );
  }

  Future<AsyncSnapshot<ItemModel>> updateItemStock({
    required String id,
    required int stock,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    AsyncSnapshot<Response> snapshot = await post(subRoute: itemStockRoute.replaceFirst("{item_id}", id), token: accessToken, queryParameters: {
      'stock': stock,
    });

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withError(ConnectionState.done, response);
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      ItemModel.fromMap(response.data),
    );
  }

  Future<AsyncSnapshot<ItemModel>> updateItemImage({
    required String id,
    required File image,
    required int index,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    AsyncSnapshot<Response> snapshot = await postUpload(
      subRoute: itemImageRoute.replaceFirst("{item_id}", id),
      token: accessToken,
      queryParameters: {
        'index': index,
      },
      file: image,
    );

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withError(ConnectionState.done, response);
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      ItemModel.fromMap(response.data),
    );
  }

  Future<AsyncSnapshot<ItemModel>> deleteItemImage({
    required String id,
    required int index,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    AsyncSnapshot<Response> snapshot = await delete(subRoute: itemImageRoute.replaceFirst("{item_id}", id), token: accessToken, queryParameters: {
      'index': index,
    });

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withError(ConnectionState.done, response);
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      ItemModel.fromMap(response.data),
    );
  }

  Future<AsyncSnapshot<ItemModel>> updateItem({
    required String id,
    String? title,
    String? subtitle,
    String? description,
    double? price,
    String? brand,
    String? category,
    Iterable<String>? addTags,
    Iterable<String>? removeTags,
    Iterable<String>? tags,
    int? stock,
    List<ModificationButton>? modificationButtons,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    AsyncSnapshot<Response> snapshot = await patch(subRoute: itemRoute.replaceFirst("{item_id}", id), token: accessToken, data: {
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
    });

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withError(ConnectionState.done, response);
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      ItemModel.fromMap(response.data),
    );
  }

  Future<AsyncSnapshot<bool>> deleteItem({
    required String id,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    AsyncSnapshot<Response> snapshot = await delete(subRoute: itemRoute.replaceFirst("{item_id}", id), token: accessToken);

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withError(ConnectionState.done, response);
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      response.data['success'] ?? false,
    );
  }

  Future<AsyncSnapshot<ItemModel>> addReview({
    required String id,
    required double rating,
    required String textContent,
    required List<Uint8List> images,
    required bool anonymous,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    AsyncSnapshot<Response> snapshot = await post(subRoute: itemReviewRoute.replaceFirst("{item_id}", id), token: accessToken, queryParameters: {
      'anonymous': anonymous,
    }, data: {
      "rating": rating,
      'text_content': textContent,
      'images': images.map((e) => base64Encode(e)).toList()
    });

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withError(ConnectionState.done, response);
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      ItemModel.fromMap(response.data),
    );
  }

  Future<AsyncSnapshot<ItemModel>> deleteReview({
    required String id,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    AsyncSnapshot<Response> snapshot = await delete(subRoute: itemReviewRoute.replaceFirst("{item_id}", id), token: accessToken);

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    if (response.statusCode! > 300) {
      return AsyncSnapshot.withError(ConnectionState.done, response);
    }

    return AsyncSnapshot.withData(
      ConnectionState.done,
      ItemModel.fromMap(response.data),
    );
  }
}
