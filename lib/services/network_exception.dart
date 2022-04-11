import 'package:dio/dio.dart';

class NetworkException implements Exception {
  final Response? response;
  final String? message;

  NetworkException({this.response, this.message});
}