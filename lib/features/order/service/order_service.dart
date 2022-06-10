import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/features/business/models/order.dart';
import 'package:vivity/services/service_provider.dart';

import '../../business/models/order_item.dart';

class OrderService extends ServiceProvider {
  static final OrderService _orderService = OrderService._();

  final AuthenticationRepository _authRepository = AuthenticationRepository();

  OrderService._() : super(baseRoute: businessOrdersRoute);

  factory OrderService() => _orderService;

  Future<AsyncSnapshot<Order>> updateOrderStatus({
    required String orderId,
    required OrderItem item,
    required OrderStatus status,
  }) async {
    AsyncSnapshot<Response> snapshot = await post(subRoute: '/status', token: await _authRepository.getAccessToken(), data: {
      'order_id': orderId,
      'status': status.index,
      'item': item.toMap(),
    });
    snapshot = checkFaultyAndTransformResponse(snapshot);

    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    return AsyncSnapshot.withData(
      ConnectionState.done,
      Order.fromMap(response.data),
    );
  }
}
