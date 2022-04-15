import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:objectid/objectid/objectid.dart';
import 'package:vivity/config/routes/routes_config.dart';
import 'package:vivity/features/auth/auth_page.dart';
import 'package:vivity/features/auth/bloc/auth_bloc.dart';
import 'package:vivity/features/business/business_page.dart';
import 'package:vivity/features/business/create_business.dart';
import 'package:vivity/features/business/unapproved_business_page.dart';
import 'package:vivity/features/home/home_bloc.dart';
import 'package:vivity/features/home/home_page.dart';
import 'package:vivity/features/item/favorites_page.dart';
import 'package:vivity/features/item/item_page/item_page.dart';
import 'package:vivity/features/splash_screen.dart';
import 'package:vivity/features/user/profile_page.dart';
import 'package:vivity/models/navigation_models.dart';
import 'package:vivity/services/item_service.dart';

import '../../features/admin/admin_page.dart';
import '../../features/error_page.dart';
import '../../features/item/models/item_model.dart';

Handler errorRouteHandler = Handler(
  handlerFunc: (BuildContext? ctx, Map<String, dynamic> params) {
    return ErrorPage(message: ctx?.settings?.arguments as String?);
  },
);

Handler authRouteHandler = Handler(handlerFunc: (BuildContext? ctx, Map<String, dynamic> params) {
  return BlocProvider(
    create: (ctx) {
      final AuthBloc authBloc = AuthBloc();
      return authBloc;
    },
    child: AuthPage(),
  );
});

Handler homeRouteHandler = Handler(handlerFunc: (BuildContext? ctx, Map<String, dynamic> params) {
  String page = params['page'][0].toLowerCase();
  bool isExplore = page == 'explore';
  return BlocProvider(
    create: (ctx) {
      HomeBloc bloc = HomeBloc();
      bloc.add(HomeLoadEvent());
      return bloc;
    },
    child: HomePage(initial: isExplore ? 0 : 1),
  );
});

Handler itemIdRouteHandler = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    String token = params['token'][0];
    String id = params['id'][0];

    return SplashScreen<ItemModel?>(
      future: getItemFromId(token, ObjectId.fromHexString(id)),
      onComplete: (BuildContext ctx, AsyncSnapshot<ItemModel?> snapshot) {
        if (snapshot.hasError) {
          router.navigateTo(ctx, '/error', routeSettings: RouteSettings(arguments: snapshot.error.toString()));
        } else if (!snapshot.hasData) {
          router.navigateTo(ctx, '/error', routeSettings: RouteSettings(arguments: "Failed to find item with ID\n${id}"));
        } else {
          router.navigateTo(ctx, '/item', routeSettings: RouteSettings(arguments: ItemPageNavigation(item: snapshot.data!, isView: true)));
        }
      },
    );
  },
);

Handler itemRouteHandler = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    if (context?.settings?.arguments is! ItemPageNavigation) {
      return ErrorPage(message: "Must pass 'ItemPageNavigation' to /item route");
    }

    ItemPageNavigation nav = context?.settings?.arguments as ItemPageNavigation;
    return ItemPage(item: nav.item, registerView: nav.isView);
  },
);

Handler profileRoute = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) => ProfilePage());

Handler settingsRoute = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) => ProfilePage());

Handler businessRoute = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) => BusinessPage());

Handler unapprovedBusinessRoute = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) => UnapprovedBusinessPage());

Handler createBusinessRoute = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) => CreateBusiness());

Handler adminPanelRoute = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) => AdminPage());

Handler favoritesRoute = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) => FavoritesPage());

Handler logoutRoute = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    Navigator.popUntil(context!, (route) => route.isFirst);
    return AuthPage();
  },
);
