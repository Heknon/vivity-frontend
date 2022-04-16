import 'package:vivity/services/service_provider.dart';

class CheckoutService extends ServiceProvider {
  static final CheckoutService _checkoutService = CheckoutService._();

  CheckoutService._();

  factory CheckoutService() => _checkoutService;
}
