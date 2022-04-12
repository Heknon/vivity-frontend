import 'package:dio/dio.dart';
import 'package:vivity/services/network_exception.dart';

class CartException extends NetworkException {
  CartException({Response? response, String? message})
      : super(message: message, response: response);
}

class CartFetchException extends NetworkException {
  CartFetchException({Response? response, String? message})
      : super(message: message, response: response);
}
