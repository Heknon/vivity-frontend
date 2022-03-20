import 'dart:convert';

import 'package:http/http.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/user/models/address.dart';
import 'package:vivity/services/api_service.dart';

Future<List<Address>> getAddress(String token, Address address) async {
  Response res = await sendGetRequest(subRoute: addressPath, token: token);
  List<dynamic> parsed = jsonDecode(res.body);

  return parsed.map((e) => Address.fromMap(e)).toList();
}

Future<List<Address>> addAddress(String token, Address address) async {
  Response res = await sendPostRequest(subRoute: addressPath, token: token, data: address.toMap());
  List<dynamic> parsed = jsonDecode(res.body);

  return parsed.map((e) => Address.fromMap(e)).toList();
}

Future<Response> removeAddress(String token, int index) async {
  return await sendDeleteRequest(subRoute: "$addressPath?index=$index", token: token);
}