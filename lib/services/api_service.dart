import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:vivity/constants/api_path.dart';

Future<http.Response> sendGetRequest({required String subRoute, String? token}) {
  return http.get(
    Uri.parse(host + subRoute),
    headers: token != null ? {"Authorization": token} : {},
  );
}

Future<http.Response> sendPostRequest({required String subRoute, String? token, Map<dynamic, dynamic>? data}) async {
  Map<String, String> headers = {
    HttpHeaders.acceptHeader: '*',
    HttpHeaders.contentTypeHeader: 'application/json',
  };

  if (token != null) {
    headers["Authorization"] = token;
  }

  String body = json.encode(data);
  return http.post(
    Uri.parse(host + subRoute),
    headers: {"Content-Type": "application/json"},
    body: body,
  );
}

Future<http.Response> sendDeleteRequest({required String subRoute, String? token}) {
  return http.delete(
    Uri.parse(host + subRoute),
    headers: token != null ? {"Authorization": token} : {},
  );
}

Future<http.Response> sendPatchRequest({required String subRoute, String? token, Map<dynamic, dynamic>? data}) {
  return http.patch(
    Uri.parse(host + subRoute),
    headers: token != null ? {"Authorization": token, "Content-Type": "application/json"} : {"Content-Type": "application/json"},
    body: json.encode(data),
  );
}
