import 'package:vivity/features/cart/service/cart_service.dart';

class CartRepository {
  static final CartRepository _cartRepository = CartRepository._();

  final CartService _cartService = CartService();

  CartRepository._();
  factory CartRepository() => _cartRepository;
}