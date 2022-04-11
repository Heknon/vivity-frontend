import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vivity/constants/api_path.dart';
import '../features/user/models/user_options.dart';
import 'auth_service.dart';
import 'package:vivity/services/api_service.dart';

import '../features/business/models/order.dart';

Future<Map<String, dynamic>?> getUserFromToken(String token) async {
  JWT? parsedToken = parseAccessToken(token);
  if (parsedToken == null) return null;

  Response response = await sendGetRequest(subRoute: userRoute, token: token);
  return response.data;
}

Future<Response?> updateProfilePicture(String token, File? file) async {
  Response response = await sendPostRequestUploadFile(subRoute: profilePictureRoute, file: file, token: token);
  if (response.statusCode! > 300) return null;

  return response;
}

Future<File?> getProfilePicture(String token) async {
  Response response = await sendGetRequest(subRoute: profilePictureRoute, token: token, contentType: "image/png", responseType: ResponseType.bytes);
  if (response.statusCode! > 300) return null;

  String path = (await getTemporaryDirectory()).path;
  return response.data.length < 10 ? null : File('$path/pfp_vivity_user.png').writeAsBytes(response.data);
}

Future<List<Order>?> getOrdersFromIds(String token, List<String> orderIds) async {
  if (orderIds.isEmpty) return null;
  Response response = await sendGetRequest(subRoute: ordersRoute + '?order_ids=${orderIds.join(',')}', token: token);
  if (response.statusCode! > 300) return null;

  return (response.data as List<dynamic>).map((e) => Order.fromMap(e)).toList();
}

Future<dynamic> updateUser(String token, {String? email, String? phone, Unit? unit, String? currencyType}) async {
  Response response = await sendPatchRequest(
      subRoute: userRoute,
      data: {
        "unit": unit?.index,
        "currency_type": currencyType,
        "email": email,
        "phone": phone,
      },
      token: token);

  if (response.statusCode! > 300) {
    return null;
  }

  return {
    'options': UserOptions.fromMap(response.data['options']),
    'access_token': response.data['access_token'],
    'email': response.data['email'],
    'phone': response.data['phone'],
  };
}

Future<Response> updatePassword(
  String token,
  String previousPassword,
  String newPassword,
) async {
  Response response = await sendPostRequest(
      subRoute: userPasswordRoute,
      data: {
        "old_password": previousPassword,
        "new_password": newPassword,
      },
      token: token);

  return response;
}

Future<Response> disableOTP(String token) async {
  Response response = await sendDeleteRequest(subRoute: userOtpRoute, token: token);
  return response;
}

Future<Response> enableOTP(String token) async {
  Response response = await sendPostRequest(subRoute: userOtpRoute, token: token);
  return response;
}
