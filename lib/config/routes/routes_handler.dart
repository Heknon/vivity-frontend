import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivity/config/routes/routes_config.dart';
import 'package:vivity/features/admin/bloc/admin_page_bloc.dart';
import 'package:vivity/features/auth/auth_page.dart';
import 'package:vivity/features/auth/bloc/auth_bloc.dart';
import 'package:vivity/features/business/bloc/business_bloc.dart';
import 'package:vivity/features/business/business_page.dart';
import 'package:vivity/features/business/create_business/bloc/create_business_bloc.dart';
import 'package:vivity/features/business/create_business/create_business.dart';
import 'package:vivity/features/business/unapproved_business_page.dart';
import 'package:vivity/features/cart/bloc/cart_bloc.dart';
import 'package:vivity/features/checkout/checkout_page/bloc/checkout_confirm_bloc.dart';
import 'package:vivity/features/checkout/checkout_page/confirm_page.dart';
import 'package:vivity/features/checkout/payment_page/bloc/payment_bloc.dart';
import 'package:vivity/features/checkout/payment_page/payment_page.dart';
import 'package:vivity/features/checkout/shipping_page/bloc/shipping_bloc.dart';
import 'package:vivity/features/checkout/shipping_page/pickup_page.dart';
import 'package:vivity/features/checkout/shipping_page/shipping_page.dart';
import 'package:vivity/features/home/bloc/home_bloc.dart';
import 'package:vivity/features/home/explore/bloc/explore_bloc.dart';
import 'package:vivity/features/home/home_page.dart';
import 'package:vivity/features/item/favorites_page/bloc/favorites_bloc.dart';
import 'package:vivity/features/item/favorites_page/favorites_page.dart';
import 'package:vivity/features/item/item_page/item_page.dart';
import 'package:vivity/features/item/repo/item_repository.dart';
import 'package:vivity/features/settings/bloc/settings_bloc.dart';
import 'package:vivity/features/settings/settings_page.dart';
import 'package:vivity/features/splash_screen.dart';
import 'package:vivity/features/user/profile_bloc/profile_bloc.dart';
import 'package:vivity/features/user/profile_page.dart';
import 'package:vivity/models/navigation_models.dart';
import 'package:vivity/models/shipping_method.dart';

import '../../features/admin/admin_page.dart';
import '../../features/error_page.dart';
import '../../features/item/models/item_model.dart';

Handler errorRouteHandler = Handler(
  handlerFunc: (BuildContext? ctx, Map<String, dynamic> params) {
    return ErrorPage(message: ctx?.settings?.arguments as String?);
  },
);

Handler authRouteHandler = Handler(
  handlerFunc: (BuildContext? ctx, Map<String, dynamic> params) => BlocProvider(
    create: (ctx) => AuthBloc(),
    child: AuthPage(),
  ),
);

Handler homeRouteHandler = Handler(handlerFunc: (BuildContext? ctx, Map<String, dynamic> params) {
  String page = params['page'][0].toLowerCase();
  bool isExplore = page == 'explore';
  return BlocProvider(
    create: (ctx) => HomeBloc()..add(HomeLoadEvent()),
    child: HomePage(initial: isExplore ? 0 : 1),
  );
});

Handler itemIdRouteHandler = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    String id = params['id'][0];

    return SplashScreen<ItemModel?>(
      future: ItemRepository().getItemFromId(itemId: id),
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

Handler profileRoute = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) => BlocProvider(
    create: (context) => ProfileBloc()..add(ProfileLoadEvent()),
    child: ProfilePage(),
  ),
);

Handler settingsRoute = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) => BlocProvider(
    create: (context) => SettingsBloc()..add(SettingsLoadEvent()),
    child: SettingsPage(),
  ),
);

Handler businessRoute = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) => BlocProvider(
    create: (context) => BusinessBloc()..add(BusinessLoadEvent()),
    child: BusinessPage(),
  ),
);

Handler unapprovedBusinessRoute = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) => BlocProvider(
    create: (context) => BusinessBloc()..add(BusinessLoadEvent()),
    child: UnapprovedBusinessPage(),
  ),
);

Handler createBusinessRoute = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) => BlocProvider(
    create: (context) => CreateBusinessBloc(),
    child: CreateBusiness(),
  ),
);

Handler adminPanelRoute = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) => BlocProvider(
    create: (context) => AdminPageBloc()..add(AdminPageLoadEvent()),
    child: AdminPage(),
  ),
);

Handler favoritesRoute = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) => BlocProvider(
    create: (context) => FavoritesBloc()..add(FavoritesLoadEvent()),
    child: FavoritesPage(),
  ),
);

Handler logoutRoute = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    Navigator.popUntil(context!, (route) => route.isFirst);
    return BlocProvider(
      create: (context) => AuthBloc()..add(AuthLogoutEvent(context.read<ExploreBloc>())),
      child: AuthPage(),
    );
  },
);

Handler checkoutConfirmRoute = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    return BlocProvider(
      create: (context) => CheckoutConfirmBloc()..add(CheckoutConfirmLoadEvent(context.read<CartBloc>())),
      child: ConfirmPage(),
    );
  },
);

Handler checkoutShippingRoute = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    CheckoutConfirmBloc bloc = context?.settings?.arguments! as CheckoutConfirmBloc;
    CheckoutConfirmLoaded loadedConfirm = bloc.state as CheckoutConfirmLoaded;

    return BlocProvider(
      create: (context) => ShippingBloc()..add(ShippingLoadEvent(bloc)),
      child: loadedConfirm.shippingMethod == ShippingMethod.pickup ? PickupPage() : ShippingPage(),
    );
  },
);

Handler checkoutPaymentRoute = Handler(
  handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
    List<dynamic> arguments = context?.settings?.arguments! as List<dynamic>;
    ShippingBloc bloc = arguments[0] as ShippingBloc;

    return BlocProvider(
      create: (context) => PaymentBloc()..add(PaymentLoadEvent(bloc, arguments[1] ?? null)),
      child: PaymentPage(),
    );
  },
);
