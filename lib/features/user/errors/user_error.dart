import 'package:dio/dio.dart';
import 'package:vivity/services/network_exception.dart';

class UserException extends NetworkException {
  UserException({Response? response, String? message}) : super(response: response, message: message);
}

class UserGetFailedException extends UserException {
  UserGetFailedException({Response? response, String? message}) : super(response: response, message: message);
}

class UserUpdateFailedException extends UserException {
  UserUpdateFailedException({Response? response, String? message}) : super(response: response, message: message);
}

class UserGetProfilePictureFailedException extends UserException {
  UserGetProfilePictureFailedException({Response? response, String? message}) : super(response: response, message: message);
}

class UserFavoriteFailedException extends UserException {
  UserFavoriteFailedException({Response? response, String? message}) : super(response: response, message: message);
}

class UserRemoveFavoriteFailedException extends UserException {
  UserRemoveFavoriteFailedException({Response? response, String? message}) : super(response: response, message: message);
}

class UserNoAccessException extends UserException {
  UserNoAccessException({Response? response, String? message}) : super(response: response, message: message);
}
