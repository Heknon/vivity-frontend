import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/features/business/error/business_error.dart';
import 'package:vivity/features/business/models/business.dart';
import 'package:vivity/features/business/service/business_service.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/features/item/repo/item_repository.dart';
import 'package:vivity/features/user/errors/user_error.dart';
import 'package:vivity/features/business/models/order.dart';
import 'package:latlong2/latlong.dart';

class UserBusinessRepository {
  static final UserBusinessRepository _userBusinessRepository = UserBusinessRepository._();
  final BusinessService _businessService = BusinessService();
  final ItemRepository _itemRepository = ItemRepository();

  UserBusinessRepository._();

  factory UserBusinessRepository() => _userBusinessRepository;

  Business? _business;
  List<Order>? _orders;
  List<ItemModel>? _items;

  Future<Business> getBusiness({bool update = false}) async {
    if (_business != null && !update) return _business!;

    AsyncSnapshot<Business> snapshot = await _businessService.getUserBusiness();
    if (snapshot.hasError || !snapshot.hasData) {
      throw UserNoAccessException(response: snapshot.error is Response ? snapshot.error as Response : null);
    }

    Business business = snapshot.data!;
    _business = business;
    return _business!;
  }

  Future<Business> updateBusiness({
    String? name,
    String? email,
    String? phone,
    String? instagram,
    String? twitter,
    String? facebook,
    double? latitude,
    double? longitude,
    bool updateDatabase = false,
  }) async {
    if (updateDatabase) {
      AsyncSnapshot<Business> snapshot = await _businessService.updateUserBusiness(
        name: name,
        email: email,
        phone: phone,
        latitude: latitude,
        longitude: longitude,
        facebook: facebook,
        instagram: instagram,
        twitter: twitter,
      );
      if (snapshot.hasError || !snapshot.hasData) {
        throw BusinessUpdateException(response: snapshot.error is Response ? snapshot.error as Response : null);
      }

      Business business = snapshot.data!;
      _business = business;
      return _business!;
    }

    Business business = await getBusiness();
    _business = business.copyWith(
      name: name,
      contact: business.contact.copyWith(
        email: email,
        phone: phone,
        twitter: twitter,
        instagram: instagram,
        facebook: facebook,
      ),
      location: latitude != null && longitude != null ? LatLng(latitude, longitude) : null,
    );

    return _business!;
  }

  /// 100% network function
  Future<Business> createBusiness({
    required String name,
    required String email,
    required String phone,
    required double latitude,
    required double longitude,
    required String nationalBusinessId,
    required File ownerId,
  }) async {
    AsyncSnapshot<Business> snapshot = await _businessService.createBusiness(
      name: name,
      email: email,
      phone: phone,
      latitude: latitude,
      longitude: longitude,
      nationalBusinessId: nationalBusinessId,
      ownerId: ownerId,
    );

    if (snapshot.hasError || !snapshot.hasData) {
      throw BusinessCreationException(response: snapshot.error is Response ? snapshot.error as Response : null);
    }

    Business business = snapshot.data!;
    _business = business;
    return _business!;
  }

  Future<List<Order>> getBusinessOrders({bool update = false}) async {
    if (_orders != null && !update) return _orders!;

    AsyncSnapshot<List<Order>> snapshot = await _businessService.getBusinessOrders();
    if (snapshot.hasError || !snapshot.hasData) {
      throw UserNoAccessException(response: snapshot.error is Response ? snapshot.error as Response : null);
    }

    List<Order> orders = snapshot.data!;
    _orders = orders;
    return _orders!;
  }

  Future<List<ItemModel>> getBusinessItems({bool update = false, bool fetchImages = false}) async {
    if (_items != null && !update) return _items!;

    _business = await getBusiness(update: update);
    List<ItemModel?> models = (await _itemRepository.getItemModelsFromId(itemIds: _business!.items.map((e) => e.hexString).toList()));
    List<ItemModel> filteredResult = List.empty(growable: true);
    for (var model in models) {
      if (model != null) filteredResult.add(model);
    }

    _items = filteredResult;
    return _items!;
  }

  void dispose() {
    _items = null;
    _orders = null;
    _business = null;
  }
}
