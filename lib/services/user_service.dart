import 'package:dio/dio.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/services/api_service.dart';

import '../features/user/models/user_options.dart';

Future<dynamic> updateUser(String token, {String? email, String? phone, Unit? unit, String? currencyType}) async {
  Response response = await sendPatchRequest(subRoute: userRoute, data: {
    "unit": unit?.index,
    "currency_type": currencyType,
    "email": email,
    "phone": phone,
  }, token: token);

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