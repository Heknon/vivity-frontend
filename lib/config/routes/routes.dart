import 'package:fluro/fluro.dart';
import 'package:vivity/config/routes/routes_config.dart';
import 'package:vivity/config/routes/routes_handler.dart';

void initRoutes() {
  router.define('/home/:page', handler: homeRouteHandler, transitionType: TransitionType.fadeIn, transitionDuration: Duration(seconds: 1));
  router.define('/auth', handler: authRouteHandler, transitionType: TransitionType.fadeIn, transitionDuration: Duration(seconds: 1));
  router.define('/error', handler: errorRouteHandler, transitionType: TransitionType.fadeIn, transitionDuration: Duration(seconds: 1));
  router.define('/profile', handler: profileRoute, transitionType: TransitionType.fadeIn, transitionDuration: Duration(seconds: 1));
  router.define('/settings', handler: settingsRoute, transitionType: TransitionType.fadeIn, transitionDuration: Duration(seconds: 1));
  router.define('/business', handler: businessRoute, transitionType: TransitionType.fadeIn, transitionDuration: Duration(seconds: 1));
  router.define('/business/unapproved', handler: unapprovedBusinessRoute, transitionType: TransitionType.fadeIn, transitionDuration: Duration(seconds: 1));
  router.define('/business/create', handler: createBusinessRoute, transitionType: TransitionType.fadeIn, transitionDuration: Duration(seconds: 1));
  router.define('/admin', handler: adminPanelRoute, transitionType: TransitionType.fadeIn, transitionDuration: Duration(seconds: 1));
  router.define('/logout', handler: logoutRoute, transitionType: TransitionType.fadeIn, transitionDuration: Duration(seconds: 1));
  router.define('/favorites', handler: favoritesRoute, transitionType: TransitionType.fadeIn, transitionDuration: Duration(seconds: 1));
  router.define('/item', handler: itemRouteHandler, transitionType: TransitionType.fadeIn, transitionDuration: Duration(seconds: 1));
  router.define('/item/:token/:id', handler: itemIdRouteHandler);
  router.define('/checkout/confirm', handler: checkoutConfirmRoute);
  router.define('/checkout/shipping', handler: checkoutShippingRoute);
  router.define('/checkout/payment', handler: checkoutPaymentRoute);
}