import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final Response? response;

  NetworkException({this.response});
}