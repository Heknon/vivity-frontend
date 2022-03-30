import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/services/api_service.dart';

import '../../models/order.dart';

Future<Map<String, dynamic>?> getUserFromToken(String token) async {
  if (JwtDecoder.isExpired(token)) return null;

  Response response = await sendGetRequest(subRoute: userRoute, token: token);
  return response.data;
}

Future<Response?> updateProfilePicture(String token, File? file) async {
  Response response = await sendPostRequestUploadFile(subRoute: profilePictureRoute, file: file, token: token);
  if (response.statusCode != 200) return null;

  return response;
}

Future<File?> getProfilePicture(String token) async {
  Response response = await sendGetRequest(subRoute: profilePictureRoute, token: token, contentType: "image/png", responseType: ResponseType.bytes);
  if (response.statusCode != 200) return null;

  String path = (await getTemporaryDirectory()).path;
  return response.data.length < 10 ? null : File('$path/pfp_vivity_user.png').writeAsBytes(response.data);
}

Future<List<Order>?> getOrdersFromIds(String token, List<String> orderIds) async {
  if (orderIds.isEmpty) return null;
  Response response = await sendGetRequest(subRoute: ordersRoute + '?order_ids=${orderIds.join(',')}', token: token);
  if (response.statusCode != 200) return null;

  return (response.data as List<dynamic>).map((e) => Order.fromMap(e)).toList();
}
