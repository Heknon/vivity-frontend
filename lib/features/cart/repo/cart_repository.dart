import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/features/cart/errors/cart_exceptions.dart';
import 'package:vivity/features/cart/models/cart_item_model.dart';
import 'package:vivity/features/cart/service/cart_service.dart';

class CartRepository {
  static final CartRepository _cartRepository = CartRepository._();

  final CartService _cartService = CartService();

  CartRepository._();

  factory CartRepository() => _cartRepository;

  List<CartItemModel>? _cart;

  Future<List<CartItemModel>> getCart({
    bool update = false,
    bool fetchImages = false,
  }) async {
    if (_cart != null && !update) return _cart!;

    AsyncSnapshot<List<CartItemModel>> snapshot =
        await _cartService.getCartItems(
      fetchImages: fetchImages,
      update: update,
    );

    if (snapshot.hasError || !snapshot.hasData) {
      throw CartFetchException(
        response:
            snapshot.error is Response ? snapshot.error! as Response : null,
      );
    }

    List<CartItemModel> cartItems = snapshot.data!;
    _cart = cartItems;
    return _cart!.map((e) => e.copyWith()).toList();
  }

  Future<List<CartItemModel>> replaceCart({
    required List<CartItemModel> cartItems,
    required bool updateDatabase,
    bool update = false,
    bool fetchImages = false,
  }) async {
    if (updateDatabase) {
      AsyncSnapshot<List<CartItemModel>> snapshot =
          await _cartService.replaceCart(
        cartItems: cartItems,
        fetchImages: fetchImages,
        update: update,
      );

      if (snapshot.hasError || !snapshot.hasData) {
        throw CartFetchException(
          response:
              snapshot.error is Response ? snapshot.error! as Response : null,
        );
      }

      List<CartItemModel> items = snapshot.data!;
      _cart = items;
      return _cart!.map((e) => e.copyWith()).toList();
    }

    _cart = cartItems;
    return _cart!.map((e) => e.copyWith()).toList();
  }

  Future<List<CartItemModel>> addItemToCart({
    required CartItemModel cartItem,
    required bool updateDatabase,
    bool update = false,
    bool fetchImages = false,
  }) async {
    List<CartItemModel> cartItems = await _cartRepository.getCart(update: update, fetchImages: fetchImages);
    cartItems.add(cartItem);

    if (updateDatabase) {
      AsyncSnapshot<List<CartItemModel>> snapshot =
      await _cartService.replaceCart(
        cartItems: cartItems,
        fetchImages: fetchImages,
        update: update,
      );

      if (snapshot.hasError || !snapshot.hasData) {
        throw CartFetchException(
          response:
          snapshot.error is Response ? snapshot.error! as Response : null,
        );
      }

      List<CartItemModel> items = snapshot.data!;
      _cart = items;
      return _cart!.map((e) => e.copyWith()).toList();
    }

    _cart = cartItems;
    return _cart!.map((e) => e.copyWith()).toList();
  }

  Future<List<CartItemModel>> removeItemFromCart({
    required CartItemModel cartItem,
    required bool updateDatabase,
    bool update = false,
    bool fetchImages = false,
  }) async {
    List<CartItemModel> cartItems = await _cartRepository.getCart(update: update, fetchImages: fetchImages);
    cartItems.removeWhere((e) => e == cartItem);

    if (updateDatabase) {
      AsyncSnapshot<List<CartItemModel>> snapshot =
      await _cartService.replaceCart(
        cartItems: cartItems,
        fetchImages: fetchImages,
        update: update,
      );

      if (snapshot.hasError || !snapshot.hasData) {
        throw CartFetchException(
          response:
          snapshot.error is Response ? snapshot.error! as Response : null,
        );
      }

      List<CartItemModel> items = snapshot.data!;
      _cart = items;
      return _cart!.map((e) => e.copyWith()).toList();
    }

    _cart = cartItems;
    return _cart!.map((e) => e.copyWith()).toList();
  }

  void dispose() {
    _cart = null;
  }
}
