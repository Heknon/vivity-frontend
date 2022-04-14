import 'package:dio/dio.dart';
import 'package:vivity/services/network_exception.dart';

class SearchException extends NetworkException {
  SearchException({Response? response, String? message}) : super(response: response, message: message);
}