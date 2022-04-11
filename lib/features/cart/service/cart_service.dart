import 'package:flutter/cupertino.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/services/service_provider.dart';

class CartService extends ServiceProvider {
  static final CartService _cartService = CartService._();

  final AuthenticationRepository _authRepository = AuthenticationRepository();

  CartService._() : super(baseRoute: cartRoute);
  factory CartService() => _cartService;

}