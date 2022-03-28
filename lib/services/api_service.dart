import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:charset/charset.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/services/http_service.dart';

/// Pass context to handle 401 responses
Future<Response> sendGetRequest({
  required String subRoute,
  String? token,
  BuildContext? context,
  String contentType = 'application/json',
  ResponseType? responseType,
}) {
  return dioClient.get(
    host + subRoute,
    options: Options(
      headers: buildHeaders(token: token, contentType: contentType),
      responseType: responseType,
    ),
  )..then((res) {
      if (res.statusCode != 401) return;

      encounter401Routine(context);
    });
}

Future<Response> sendPostRequest({
  required String subRoute,
  String? token,
  dynamic data,
  String contentType = 'application/json',
  BuildContext? context,
  ResponseType? responseType,
}) async {
  String body = json.encode(data);
  return dioClient.post(
    host + subRoute,
    options: Options(
      headers: buildHeaders(token: token, contentType: contentType),
      responseType: responseType,
    ),
    data: body,
  )..then((res) {
      if (res.statusCode != 401) return;

      encounter401Routine(context);
    });
}

Future<Response> sendPostRequestUploadFile({
  required String subRoute,
  required File? file,
  String? token,
  BuildContext? context,
  ResponseType? responseType,
}) async {
  Uint8List data = await file?.readAsBytes() ?? Uint8List(0);

  return dioClient.post(
    host + subRoute,
    options: Options(
      headers: buildHeaders(token: token, contentType: 'text/plain'),
      responseType: responseType,
      requestEncoder: (_, a) => data.toList(),
    ),
    data: data,
  )..then((res) {
      if (res.statusCode != 401) return;

      encounter401Routine(context);
    });
}

Future<Response> sendDeleteRequest({
  required String subRoute,
  String? token,
  BuildContext? context,
  String? contentType,
  ResponseType? responseType,
}) {
  return dioClient.delete(
    host + subRoute,
    options: Options(
      headers: buildHeaders(token: token, contentType: contentType),
      responseType: responseType,
    ),
  )..then((res) {
      if (res.statusCode != 401) return;

      encounter401Routine(context);
    });
}

Future<Response> sendPatchRequest({
  required String subRoute,
  String? token,
  dynamic data,
  String contentType = 'application/json',
  BuildContext? context,
  ResponseType? responseType,
}) {
  return dioClient.patch(
    host + subRoute,
    options: Options(
      headers: buildHeaders(token: token, contentType: contentType),
      responseType: responseType,
    ),
    data: json.encode(data),
  )..then((res) {
      if (res.statusCode != 401) return;

      encounter401Routine(context);
    });
}

String byteUuidToString(List<int> uuid) {
  return cp437.decode(uuid);
}

List<int> stringToByteUuid(String uuid) {
  return cp437.encode(uuid);
}

void encounter401Routine(BuildContext? context) {
  if (context == null) return;

  try {
    UserBloc userBloc = BlocProvider.of<UserBloc>(context);
    userBloc.add(UserRenewTokenEvent());
  } on Exception catch (e) {
    rethrow;
  }
}

Map<String, String> buildHeaders({String? token, String? contentType = 'application/json'}) {
  Map<String, String> headers = {
    HttpHeaders.acceptHeader: '*',
    HttpHeaders.contentTypeHeader: contentType ?? 'text/plain',
  };

  if (token != null) {
    headers["Authorization"] = "Bearer: $token";
  }

  return headers;
}
