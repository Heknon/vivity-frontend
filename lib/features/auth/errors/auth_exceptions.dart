import 'package:dio/dio.dart';
import 'package:vivity/services/network_exception.dart';

class AuthException extends NetworkException {
  AuthException({String? message, Response? response}) : super(message: message, response: response);
}

class AuthFailedException extends AuthException {
  AuthFailedException({String? message, Response? response}) : super(message: message, response: response);
}

class InvalidRefreshToken extends AuthException {
  InvalidRefreshToken({String? message, Response? response}) : super(message: message, response: response);
}
class InvalidAccessToken extends AuthException {
  InvalidAccessToken({String? message, Response? response}) : super(message: message, response: response);
}
