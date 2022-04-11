import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/app_system_manager.dart';
import 'package:vivity/config/routes/routes.dart';
import 'package:vivity/config/routes/routes_config.dart';
import 'package:vivity/config/themes/light_theme.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/features/auth/bloc/auth_bloc.dart';
import 'package:vivity/features/checkout/bloc/checkout_bloc.dart';
import 'package:vivity/features/splash_screen.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/models/shipping_method.dart';
import 'package:vivity/services/dio_http_service.dart';
import 'package:vivity/services/storage_service.dart';
import 'package:vivity/features/item/item_page.dart';

import 'constants/asset_path.dart';
import 'features/auth/auth_page.dart';
import 'features/auth/models/token_container.dart';
import 'services/auth_service.dart';
import 'features/cart/cart_bloc/cart_bloc.dart';
import 'features/checkout/checkout_service.dart';
import 'features/explore/bloc/explore_bloc.dart';
import 'features/home/home_page.dart';

/*
Check if CheckoutBloc is good
Check if UserBloc logic is good
Fix AuthBloc logic to use Eden's implementation

IMPLEMENT SERVICES fdshfiusdhgisosde

Create explore state
Create Feed state

Create connection between database and cart

Add hamburger menu for logout
 */

Future<TokenContainer?>? loginResult;

void main() async {
  initDioHttpServices();
  WidgetsFlutterBinding.ensureInitialized();

  HydratedStorage storage = await initializeStorage();

  initRoutes();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await loadJwtPublicKey();
  await loadImageAssets();
  HydratedBlocOverrides.runZoned(
    () => runApp(const Vivity()),
    storage: storage,
  );
}

class Vivity extends StatelessWidget {
  const Vivity({Key? key}) : super(key: key);

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (BuildContext context) => AuthBloc(),
        ),
        BlocProvider<CartBloc>(
          create: (BuildContext context) => CartBloc(),
        ),
        BlocProvider<UserBloc>(
          create: (BuildContext context) => UserBloc(),
        ),
        BlocProvider<CheckoutBloc>(
          create: (BuildContext context) => CheckoutBloc(),
        ),
        BlocProvider<ExploreBloc>(
          create: (BuildContext context) => ExploreBloc(),
        ),
      ],
      child: Sizer(
        builder: (ctx, orientation, type) {
          loginResult ??= BlocProvider.of<AuthBloc>(ctx).state.verifyCredentials();

          return AppSystemManager(
            child: MaterialApp(
              title: 'Vivity',
              theme: lightTheme,
              onGenerateRoute: router.generator,
              home: SplashScreen<TokenContainer?>(
                future: loginResult!,
                onComplete: (ctx, snapshot) {
                  ExploreBloc exploreBloc = BlocProvider.of<ExploreBloc>(ctx);
                  CartBloc cartBloc = BlocProvider.of<CartBloc>(ctx);
                  UserBloc userBloc = BlocProvider.of<UserBloc>(ctx);

                  exploreBloc.add(ExploreRegisterUserBlocListener(userBloc));
                  cartBloc.add(CartRegisterInitializer(userBloc));

                  if (snapshot.hasError || !snapshot.hasData) {
                    Navigator.pushReplacementNamed(ctx, '/auth');
                    loginResult = null;
                    return;
                  }

                  UserState userState = userBloc.state;

                  if (userState is! UserLoggedInState) {
                    userBloc.add(UserLoginEvent(snapshot.data!.accessToken));
                  }

                  Navigator.pushReplacementNamed(ctx, '/home/explore');
                  loginResult = null;
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
