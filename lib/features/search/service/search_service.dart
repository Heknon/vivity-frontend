import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlng/latlng.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/repo/item_repository.dart';
import 'package:vivity/services/service_provider.dart';

class SearchService extends ServiceProvider {
  static const searchItemsRoute = "/search";
  static const exploreItemsRoute = "/explore/item";
  static const exploreBusinessesRoute = "/explore/business";

  static final SearchService _searchService = SearchService._();
  final AuthenticationRepository _authRepository = AuthenticationRepository();
  final ItemRepository _itemRepository = ItemRepository();

  SearchService._();

  factory SearchService() => _searchService;

  Future<AsyncSnapshot<List<ItemModel>>> exploreItems({
    required LatLng position,
    required double radius,
  }) async {
    String accessToken = await _authRepository.getAccessToken();

    AsyncSnapshot<Response> snapshot = await get(
      baseRoute: exploreItemsRoute + "?radius_center=${position.latitude},${position.longitude}&radius=$radius",
      token: accessToken,
    );

    snapshot = checkFaultyAndTransformResponse(snapshot);
    if (snapshot.hasError || !snapshot.hasData) {
      return snapshot.error != null ? AsyncSnapshot.withError(snapshot.connectionState, snapshot.error!) : AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    List<ItemModel> items = (response.data as List<dynamic>).map((e) => ItemModel.fromMap(e)).toList();
    _itemRepository.gracefullyUpdateItems(items);
    return AsyncSnapshot.withData(ConnectionState.done, items);
  }

  Future<AsyncSnapshot<List<Business>>> exploreBusinesses({
    required LatLng position,
    required double radius,
  }) async {
    String accessToken = await _authRepository.getAccessToken();

    AsyncSnapshot<Response> snapshot = await get(
      baseRoute: exploreBusinessesRoute + "?radius_center=${position.latitude},${position.longitude}&radius=$radius",
      token: accessToken,
    );

    snapshot = checkFaultyAndTransformResponse(snapshot);
    if (snapshot.hasError || !snapshot.hasData) {
      return snapshot.error != null ? AsyncSnapshot.withError(snapshot.connectionState, snapshot.error!) : AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    List<Business> businesses = (response.data as List<dynamic>).map((e) => Business.fromMap(e)).toList();
    return AsyncSnapshot.withData(ConnectionState.done, businesses);
  }

  Future<AsyncSnapshot<List<ItemModel>>> search({
    required String query,
  }) async {
    String accessToken = await _authRepository.getAccessToken();

    AsyncSnapshot<Response> snapshot = await get(baseRoute: exploreItemsRoute, token: accessToken, queryParameters: {
      'query': query,
    });

    snapshot = checkFaultyAndTransformResponse(snapshot);
    if (snapshot.hasError || !snapshot.hasData) {
      return snapshot.error != null ? AsyncSnapshot.withError(snapshot.connectionState, snapshot.error!) : AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    List<ItemModel> items = (response.data as List<dynamic>).map((e) => ItemModel.fromMap(e)).toList();
    _itemRepository.gracefullyUpdateItems(items);
    return AsyncSnapshot.withData(ConnectionState.done, items);
  }
}
