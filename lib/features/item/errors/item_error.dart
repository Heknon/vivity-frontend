import 'package:dio/dio.dart';
import 'package:vivity/services/network_exception.dart';

class ItemException extends NetworkException {
  final String? message;

  ItemException({Response? response, this.message}) : super(response: response);
}

class ItemFetchFailedException extends ItemException {
  ItemFetchFailedException({Response? response, String? message}) : super(response: response, message: message);
}

class ItemCreationFailedException extends ItemException {
  ItemCreationFailedException({Response? response, String? message}) : super(response: response, message: message);
}

class ItemUpdateFailedException extends ItemException {
  ItemUpdateFailedException({Response? response, String? message}) : super(response: response, message: message);
}

class ItemUpdateStockFailedException extends ItemUpdateFailedException {
  ItemUpdateStockFailedException({Response? response, String? message}) : super(response: response, message: message);
}

class ItemUpdateImageFailedException extends ItemUpdateFailedException {
  ItemUpdateImageFailedException({Response? response, String? message}) : super(response: response, message: message);
}

class ItemDeleteFailedException extends ItemException {
  ItemDeleteFailedException({Response? response, String? message}) : super(response: response, message: message);
}

class ItemAddReviewFailedException extends ItemException {
  ItemAddReviewFailedException({Response? response, String? message}) : super(response: response, message: message);
}

class ItemDeleteReviewFailedException extends ItemException {
  ItemDeleteReviewFailedException({Response? response, String? message}) : super(response: response, message: message);
}
