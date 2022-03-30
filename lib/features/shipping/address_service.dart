import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/constants/api_path.dart';
import '../../models/address.dart';
import 'package:vivity/services/api_service.dart';

Future<List<Address>> getAddress(String token, Address address, {BuildContext? context}) async {
  Response res = await sendGetRequest(subRoute: addressRoute, token: token, context: context);

  return (res.data as List<dynamic>).map((e) => Address.fromMap(e)).toList();
}

Future<List<Address>> addAddress(String token, Address address, {BuildContext? context}) async {
  Response res = await sendPostRequest(subRoute: addressRoute, token: token, data: address.toMap(), context: context);

  return (res.data as List<dynamic>).map((e) => Address.fromMap(e)).toList();
}

Future<List<Address>> removeAddress(String token, int index, {BuildContext? context}) async {
  Response res = await sendDeleteRequest(subRoute: "$addressRoute?index=$index", token: token, context: context);

  return (res.data as List<dynamic>).map((e) => Address.fromMap(e)).toList();
}
