import 'dart:io';

import 'package:dio/dio.dart';

late final Dio dioClient;

void initDioHttpServices() {
  dioClient = Dio();
  // dioClient.options.responseDecoder = responseDecoder;
  dioClient.options.sendTimeout = 10;
  dioClient.options.receiveTimeout = 2000;
  dioClient.interceptors.add(RetryOnConnectionChangeInterceptor(dio: dioClient));
}

/// Interceptor
class RetryOnConnectionChangeInterceptor extends Interceptor {
  final Dio dio;

  RetryOnConnectionChangeInterceptor({
    required this.dio,
  });

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (_shouldRetryOnHttpException(err)) {
      try {
        handler.resolve(await DioHttpRequestRetrier(dio: dio).requestRetry(err.requestOptions).catchError((e) {
          handler.next(err);
        }));
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }

  }

  bool _shouldRetryOnHttpException(DioError err) {
    return err.type == DioErrorType.other &&
        ((err.error is HttpException && err.message.contains('Connection closed while receiving data')));
  }
}

/// Retrier
class DioHttpRequestRetrier {
  final Dio dio;

  DioHttpRequestRetrier({
    required this.dio,
  });

  Future<Response> requestRetry(RequestOptions requestOptions) async {
    return dio.request(
      requestOptions.path,
      cancelToken: requestOptions.cancelToken,
      data: requestOptions.data,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        contentType: requestOptions.contentType,
        headers: requestOptions.headers,
        sendTimeout: requestOptions.sendTimeout,
        receiveTimeout: requestOptions.receiveTimeout,
        extra: requestOptions.extra,
        followRedirects: requestOptions.followRedirects,
        listFormat: requestOptions.listFormat,
        maxRedirects: requestOptions.maxRedirects,
        method: requestOptions.method,
        receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
        requestEncoder: requestOptions.requestEncoder,
        responseDecoder: requestOptions.responseDecoder,
        responseType: requestOptions.responseType,
        validateStatus: requestOptions.validateStatus,
      ),
    );
  }
}

String responseDecoder(List<int> responseBytes, RequestOptions options, ResponseBody responseBody) {
  return "";
}