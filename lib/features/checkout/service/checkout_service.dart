import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:vivity/features/business/models/order_item.dart';
import 'package:vivity/services/service_provider.dart';
import 'package:vivity/constants/api_path.dart' as api_route;

import '../../address/models/address.dart';
import '../../auth/repo/authentication_repository.dart';
import '../../business/models/order.dart';

class CheckoutService extends ServiceProvider {
  final AuthenticationRepository _authRepository = AuthenticationRepository();

  static const String shippingCostRoute = '/shipping';
  static const String cuponDiscountRoute = '/cupon';

  static final CheckoutService _checkoutService = CheckoutService._();

  CheckoutService._() : super(baseRoute: api_route.businessOrdersRoute);

  factory CheckoutService() => _checkoutService;

  Future<AsyncSnapshot<Order>> processOrder({
    required Order order,
    required String cupon,
    required String creditCardNumber,
    required int year,
    required int month,
    required String cvv,
    required String name,
  }) async {
    String accessToken = await _authRepository.getAccessToken();
    Map<String, dynamic> orderMap = order.toMap();
    orderMap.remove("order_date");
    orderMap['cupon'] = cupon;

    AsyncSnapshot<Response> snapshot = await post(token: accessToken, data: {
      "credit_card_number": creditCardNumber,
      "year": year,
      "month": month,
      "cvv": cvv,
      "order": orderMap,
      'name': name,
    });

    return this.checkFaultyAndTransformResponse(snapshot, map: (response) => Order.fromMap(response.data));
  }

  Future<AsyncSnapshot<double>> getCuponDiscount({
    required String cupon,
  }) async {
    String accessToken = await _authRepository.getAccessToken();

    AsyncSnapshot<Response> snapshot = await get(subRoute: cuponDiscountRoute, token: accessToken, queryParameters: {'cupon': cupon});

    return this.checkFaultyAndTransformResponse(snapshot, map: (response) => response.data['discount']);
  }

  Future<AsyncSnapshot<double>> getShippingCost({
    required Address? address,
    required List<OrderItem> items,
  }) async {
    String accessToken = await _authRepository.getAccessToken();

    AsyncSnapshot<Response> snapshot = await post(subRoute: shippingCostRoute, token: accessToken, data: {
      'items': items.map((e) => e.toMap()).toList(),
      'address': address?.toMap()
    });

    return this.checkFaultyAndTransformResponse(snapshot, map: (response) => response.data['cost']);
  }
}
