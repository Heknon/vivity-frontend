import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/models/business.dart';
import 'package:vivity/services/item_service.dart';

import '../constants/api_path.dart';
import '../models/order.dart';
import 'api_service.dart';

Future<int> addBusinessView(String token, String businessId) async {
  Response response = await sendPostRequest(subRoute: businessViewMetricRoute.replaceFirst("{business_id}", businessId), token: token);
  if (response.statusCode! > 300) {
    throw Exception('Failed to update view count. $response');
  }

  return response.data;
}

Future<List<Order>> getBusinessOrders(String token) async {
  Response response = await sendGetRequest(subRoute: businessOrdersRoute, token: token);
  if (response.statusCode! > 300) {
    throw Exception('Failed to get business orders. $response');
  }

  List<Order> orders = (response.data as List<dynamic>).map((e) => Order.fromMap(e)).toList();
  return orders;
}

Future<List<ItemModel>> getItemsFromOrders(String token, List<Order> orders) async {
  Set<String> ids = {};

  for (var order in orders) {
    for (var item in order.items) {
      if (item.itemId == null) continue;
      ids.add(item.itemId!.hexString);
    }
  }

  List<ItemModel> items = await getItemsFromStringIds(token, ids.toList());
  return items;
}

Future<Order> updateOrderStatus(String token, OrderStatus status, String orderId) async {
  Response response = await sendPostRequest(subRoute: businessOrderStatusRoute, token: token, data: {
    "status": status.index,
    "order_id": orderId,
  });
  if (response.statusCode! > 300) {
    throw Exception('Failed to update order status. $response');
  }

  return Order.fromMap(response.data);
}

Future<Business> createBusiness(
  String token,
  String name,
  String email,
  String phone,
  double latitude,
  double longitude,
  String nationalBusinessId,
  File ownerId,
) async {
  Response res = await sendPostRequest(subRoute: businessRoute, token: token, data: {
    "name": name,
    "email": email,
    "phone": phone,
    "latitude": latitude,
    "longitude": longitude,
    "business_national_number": nationalBusinessId,
    "business_owner_id": base64Encode(await ownerId.readAsBytes()),
  });

  if (res.statusCode! > 300) throw Exception('Failed to create business');

  return Business.fromMap(res.data["token"], res.data["business"]);
}

Future<Business?> updateBusiness(
  String token,
  String name,
  String email,
  String phone,
  double latitude,
  double longitude,
  String nationalBusinessId,
  File ownerId,
) async {
  Response res = await sendPatchRequest(subRoute: businessRoute, data: {
    "name": name,
    "email": email,
    "phone": phone,
    "latitude": latitude,
    "longitude": longitude,
    "business_national_number": nationalBusinessId,
    "owner_id": base64Encode(await ownerId.readAsBytes()),
  });

  if (res.statusCode! > 300) throw Exception("Business doesn't exist");

  return Business.fromMap(token, res.data);
}
