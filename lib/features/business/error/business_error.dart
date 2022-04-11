import 'package:dio/dio.dart';
import 'package:vivity/services/network_exception.dart';

class BusinessException extends NetworkException {
  BusinessException({Response? response, String? message}) : super(response: response, message: message);
}

class BusinessCreationException extends NetworkException {
  BusinessCreationException({Response? response, String? message}) : super(response: response, message: message);
}

class BusinessUpdateException extends NetworkException {
  BusinessUpdateException({Response? response, String? message}) : super(response: response, message: message);
}