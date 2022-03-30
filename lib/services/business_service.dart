import 'package:dio/dio.dart';
import 'package:vivity/features/item/models/item_model.dart';
import 'package:vivity/models/business.dart';
import 'package:vivity/services/item_service.dart';

import '../constants/api_path.dart';
import '../models/order.dart';
import 'api_service.dart';

Future<int> addBusinessView(String token, String businessId) async {
  Response response = await sendPostRequest(subRoute: businessViewMetricRoute.replaceFirst("{business_id}", businessId), token: token);
  if (response.statusCode != 200) {
    throw Exception('Failed to update view count. $response');
  }

  return response.data;
}

Future<List<Order>> getBusinessOrders(String token) async {
  Response response = await sendGetRequest(subRoute: businessOrdersRoute, token: token);
  if (response.statusCode != 200) {
    throw Exception('Failed to get business orders. $response');
  }

  List<Order> orders = (response.data as List<dynamic>).map((e) => Order.fromMap(e)).toList();
  return orders;
}

Future<List<ItemModel>> getItemsFromOrders(String token, List<Order> orders) async {
  Set<String> ids = {};

  for (var order in orders) {
    for (var item in order.items) {
      ids.add(item.itemId.hexString);
    }
  }

  List<ItemModel> items = await getItemsFromStringIds(token, ids.toList());
  return items;
}