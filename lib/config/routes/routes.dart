import 'package:vivity/config/routes/routes_config.dart';
import 'package:vivity/config/routes/routes_handler.dart';

void initRoutes() {
  router.define('/', handler: initialRouteHandler);
  router.define('/home/:page', handler: homeRouteHandler);
  router.define('/auth', handler: authRouteHandler);
  router.define('/error', handler: errorRouteHandler);
  router.define('/profile', handler: profileRoute);
  router.define('/settings', handler: settingsRoute);
  router.define('/business', handler: businessRoute);
  router.define('/business/unapproved', handler: unapprovedBusinessRoute);
  router.define('/business/create', handler: createBusinessRoute);
  router.define('/admin', handler: adminPanelRoute);
  router.define('/logout', handler: logoutRoute);
  router.define('/favorites', handler: favoritesRoute);
  router.define('/item', handler: itemRouteHandler);
  router.define('/item/:token/:id', handler: itemIdRouteHandler);
}