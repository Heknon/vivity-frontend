import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/app_system_manager.dart';
import 'package:vivity/config/routes/routes.dart';
import 'package:vivity/config/routes/routes_config.dart';
import 'package:vivity/config/themes/light_theme.dart';
import 'package:vivity/features/cart/bloc/cart_bloc.dart';
import 'package:vivity/features/home/explore/bloc/explore_bloc.dart';
import 'package:vivity/features/item/liked/liked_bloc.dart';
import 'package:vivity/features/splash_screen.dart';
import 'package:vivity/features/user/models/user.dart';
import 'package:vivity/features/user/repo/user_repository.dart';

import 'constants/asset_path.dart';

Future<User>? loginResult;

// TODO: Fix forgot password not returning error message (maybe not checking old password)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initRoutes();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await loadImageAssets();

  runApp(const Vivity());
}

class Vivity extends StatelessWidget {
  const Vivity({Key? key}) : super(key: key);

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartBloc>(
          create: (BuildContext context) => CartBloc(),
        ),
        BlocProvider<LikedBloc>(
          create: (BuildContext context) => LikedBloc(),
        ),
        BlocProvider<ExploreBloc>(
          create: (BuildContext context) => ExploreBloc(),
        ),
      ],
      child: Sizer(
        builder: (ctx, orientation, type) {
          loginResult ??= UserRepository().getUser();


          return AppSystemManager(
            child: MaterialApp(
              title: 'Vivity',
              theme: lightTheme,
              onGenerateRoute: router.generator,
              home: SplashScreen<User>(
                future: loginResult!,
                onComplete: (ctx, snapshot) {
                  CartBloc cartBloc = BlocProvider.of<CartBloc>(ctx);
                  LikedBloc likedBloc = BlocProvider.of<LikedBloc>(ctx);
                  ExploreBloc exploreBloc = BlocProvider.of<ExploreBloc>(ctx);

                  if (snapshot.hasError || !snapshot.hasData) {
                    Navigator.pushReplacementNamed(ctx, '/auth');
                    loginResult = null;
                    return;
                  }

                  cartBloc.add(CartSyncEvent());
                  likedBloc.add(LikedLoadEvent());
                  exploreBloc.add(ExploreLoad());

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
