import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/repo/item_repository.dart';
import 'package:vivity/services/service_provider.dart';

class CartService extends ServiceProvider {
  static final CartService _cartService = CartService._();

  final AuthenticationRepository _authRepository = AuthenticationRepository();
  final ItemRepository _itemRepository = ItemRepository();

  CartService._() : super(baseRoute: cartRoute);

  factory CartService() => _cartService;

  Future<AsyncSnapshot<List<CartItemModel>>> getCartItems({
    required bool update,
    required bool fetchImages,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    AsyncSnapshot<Response> snapshot = await get(token: accessToken);
    snapshot = faultyResponseShouldReturn(snapshot);
    if (snapshot.hasError) {
      return AsyncSnapshot.withError(snapshot.connectionState, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    List<CartItemModel> cartItems = await _getCartItemModelsFromMap(
      response.data,
      update: update,
      fetchImages: fetchImages,
    );

    return AsyncSnapshot.withData(
      ConnectionState.done,
      cartItems,
    );
  }

  Future<AsyncSnapshot<List<CartItemModel>>> replaceCart({
    required List<CartItemModel> cartItems,
    required bool update,
    required bool fetchImages,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    List<Map<String, dynamic>> body = cartItems.map((e) => e.toMap()).toList();
    AsyncSnapshot<Response> snapshot = await post(
      token: accessToken,
      data: body,
    );
    snapshot = faultyResponseShouldReturn(snapshot);
    if (snapshot.hasError) {
      return AsyncSnapshot.withError(snapshot.connectionState, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    List<CartItemModel> cartItemsResult = await _getCartItemModelsFromMap(
      response.data,
      fetchImages: fetchImages,
      update: update,
    );

    return AsyncSnapshot.withData(
      ConnectionState.done,
      cartItemsResult,
    );
  }

  Future<List<CartItemModel>> _getCartItemModelsFromMap(
    List<dynamic> unparsedCart, {
    required bool update,
    required bool fetchImages,
  }) async {
    List<String> itemIds = List.generate(
      unparsedCart.length,
      (index) => unparsedCart[index]['item_id'],
    );

    List<ItemModel?> cartItemModels = await _itemRepository.getItemModelsFromId(
      itemIds: itemIds,
      update: update,
      fetchImagesOnUpdate: fetchImages,
    );

    List<CartItemModel> cartItemsResult = List.empty(growable: true);
    Map<String, ItemModel> itemIdModelMap = {};

    for (ItemModel? item in cartItemModels) {
      if (item != null) itemIdModelMap[item.id.hexString] = item;
    }

    for (dynamic cartItem in unparsedCart) {
      String itemId = cartItem['item_id'];
      ItemModel? model = itemIdModelMap[itemId];
      if (model == null) continue;

      cartItemsResult.add(CartItemModel.fromMap(cartItem, model));
    }
    return cartItemsResult;
  }
}
