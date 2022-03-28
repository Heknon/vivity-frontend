import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/user/models/address.dart';
import 'package:vivity/services/api_service.dart';

Future<List<Address>> getAddress(String token, Address address, {BuildContext? context}) async {
  Response res = await sendGetRequest(subRoute: addressRoute, token: token, context: context);

  return res.data.map((e) => Address.fromMap(e)).toList();
}

Future<List<Address>> addAddress(String token, Address address, {BuildContext? context}) async {
  Response res = await sendPostRequest(subRoute: addressRoute, token: token, data: address.toMap(), context: context);

  return res.data.map((e) => Address.fromMap(e)).toList();
}

Future<Response> removeAddress(String token, int index, {BuildContext? context}) async {
  return await sendDeleteRequest(subRoute: "$addressRoute?index=$index", token: token, context: context);
}