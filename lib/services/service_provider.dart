import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'dart:io' as io;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/constants/api_path.dart' as api;
import 'package:vivity/services/dio_http_service.dart';

abstract class ServiceProvider {
  final DioHttpService _dioHttpService = DioHttpService();
  final String host;
  final String baseRoute;
  final String contentType;

  ServiceProvider({this.host = api.host, this.baseRoute = '', this.contentType = 'application/json'});

  Future<AsyncSnapshot<Response>> get({
    String? baseRoute,
    String? subRoute,
    String? token,
    String? contentType,
    Map<String, dynamic>? queryParameters,
    bool Function(Response)? classifyAsErrorWhen,
  }) async {
    return _sendRequest(
      requestSender: ((
        route,
        queryParameters,
        options,
      ) =>
          _dioHttpService.client.get(route, queryParameters: queryParameters, options: options)),
      queryParameters: queryParameters,
      contentType: contentType,
      token: token,
      subRoute: subRoute,
      baseRoute: baseRoute,
      classifyAsErrorWhen: classifyAsErrorWhen,
    );
  }

  Future<AsyncSnapshot<Response>> post({
    String? baseRoute,
    String? subRoute,
    String? token,
    String? contentType,
    Map<String, dynamic>? queryParameters,
    bool Function(Response)? classifyAsErrorWhen,
    dynamic data,
  }) async {
    return _sendRequest(
      requestSender: ((route, queryParameters, options) =>
          _dioHttpService.client.post(route, queryParameters: queryParameters, options: options, data: data)),
      queryParameters: queryParameters,
      contentType: contentType,
      token: token,
      subRoute: subRoute,
      baseRoute: baseRoute,
      classifyAsErrorWhen: classifyAsErrorWhen,
    );
  }

  Future<AsyncSnapshot<Response>> postUpload({
    required io.File? file,
    String? baseRoute,
    String? subRoute,
    String? token,
    String? contentType,
    Map<String, dynamic>? queryParameters,
    bool Function(Response)? classifyAsErrorWhen,
  }) async {
    Uint8List data = await file?.readAsBytes() ?? Uint8List(0);

    return _sendRequest(
      requestSender: ((route, queryParameters, options) => _dioHttpService.client.post(route,
          queryParameters: queryParameters,
          options: Options(
            headers: options?.headers,
            requestEncoder: (_, a) => data.toList(),
          ),
          data: data)),
      queryParameters: queryParameters,
      contentType: 'text/plain',
      token: token,
      subRoute: subRoute,
      baseRoute: baseRoute,
      classifyAsErrorWhen: classifyAsErrorWhen,
    );
  }

  Future<AsyncSnapshot<Response>> patch({
    String? baseRoute,
    String? subRoute,
    String? token,
    String? contentType,
    Map<String, dynamic>? queryParameters,
    bool Function(Response)? classifyAsErrorWhen,
    dynamic data,
  }) async {
    return _sendRequest(
      requestSender: ((
        route,
        queryParameters,
        options,
      ) =>
          _dioHttpService.client.patch(route, queryParameters: queryParameters, options: options, data: data)),
      queryParameters: queryParameters,
      contentType: contentType,
      token: token,
      subRoute: subRoute,
      baseRoute: baseRoute,
      classifyAsErrorWhen: classifyAsErrorWhen,
    );
  }

  Future<AsyncSnapshot<Response>> delete({
    String? baseRoute,
    String? subRoute,
    String? token,
    String? contentType,
    Map<String, dynamic>? queryParameters,
    bool Function(Response)? classifyAsErrorWhen,
  }) async {
    return _sendRequest(
      requestSender: ((
        route,
        queryParameters,
        options,
      ) =>
          _dioHttpService.client.delete(route, queryParameters: queryParameters, options: options)),
      queryParameters: queryParameters,
      contentType: contentType,
      token: token,
      subRoute: subRoute,
      baseRoute: baseRoute,
      classifyAsErrorWhen: classifyAsErrorWhen,
    );
  }

  /// if response is has error or no data return.
  AsyncSnapshot<Response> faultyResponseShouldReturn(
    AsyncSnapshot<Response> snapshot, {
    int maximumStatusCodeForNoError = 300,
  }) {
    if (snapshot.hasError) {
      return AsyncSnapshot.withError(ConnectionState.done, snapshot.error!);
    } else if (!snapshot.hasData) {
      return AsyncSnapshot.nothing();
    }

    Response response = snapshot.data!;
    if (response.statusCode! > maximumStatusCodeForNoError) {
      return AsyncSnapshot.withError(ConnectionState.done, response);
    }

    return AsyncSnapshot.withData(ConnectionState.done, response);
  }

  Future<AsyncSnapshot<Response>> _sendRequest({
    required Future<Response> Function(String route, Map<String, dynamic>? queryParameters, Options? options) requestSender,
    String? baseRoute,
    String? subRoute,
    String? token,
    String? contentType,
    Map<String, dynamic>? queryParameters,
    bool Function(Response)? classifyAsErrorWhen,
  }) async {
    Map<String, String> headers = buildHeaders(token: token, contentType: contentType);

    try {
      Response response = await requestSender(host + (baseRoute ?? this.baseRoute) + (subRoute ?? ''), queryParameters, Options(headers: headers));
      if (classifyAsErrorWhen != null && classifyAsErrorWhen(response)) return AsyncSnapshot.withError(ConnectionState.done, response);

      return AsyncSnapshot.withData(ConnectionState.done, response);
    } on Exception catch (e) {
      return AsyncSnapshot.withError(ConnectionState.done, e);
    }
  }

  @protected
  Future<String> fileToBase64(io.File file) async {
    Uint8List contents = await file.readAsBytes();
    return base64Encode(contents);
  }

  @protected
  Future<Uint8List> base64ToFile(String base64, io.File writeTo) async {
    Uint8List decoded = base64Decode(base64);
    await writeTo.writeAsBytes(decoded);
    return decoded;
  }

  @protected
  Map<String, String> buildHeaders({String? token, String? contentType}) {
    Map<String, String> headers = {
      HttpHeaders.acceptHeader: '*',
      HttpHeaders.contentTypeHeader: contentType ?? this.contentType,
    };

    if (token != null) {
      headers[HttpHeaders.authorizationHeader] = "Bearer: $token";
    }

    return headers;
  }
}
