import 'dart:io';

import 'package:dio/dio.dart';

import '../constants/api_path.dart';
import 'api_service.dart';

Future<File?> getImage(String token, String imageId, String folderName) async {
  Response response = await sendGetRequest(subRoute: imageRoute, token: token, contentType: "image/png");
  if (response.statusCode != 200) return null;

  return response.data.length < 10 ? null : File.fromRawPath(response.data);
}