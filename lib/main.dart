import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/app_system_manager.dart';
import 'package:vivity/config/themes/light_theme.dart';
import 'package:vivity/constants/api_path.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/features/auth/bloc/auth_bloc.dart';
import 'package:vivity/features/checkout/bloc/checkout_bloc.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/models/shipping_method.dart';
import 'package:vivity/services/storage_service.dart';
import 'package:vivity/features/item/item_page.dart';

import 'features/auth/auth_page.dart';
import 'features/cart/cart_bloc/cart_bloc.dart';
import 'features/checkout/checkout_service.dart';
import 'features/home/home_page.dart';
import 'package:http/http.dart' as http;

class VivityOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    HttpClient client = super.createHttpClient(context);
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    client.connectionTimeout = const Duration(seconds: 5);
    return client;
  }
}

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

void main() async {
  HttpOverrides.global = VivityOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  HydratedStorage storage = await initializeStorage();
  // await storage.clear();

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
    navigateToCorrectCheckoutPage(CheckoutStatePaymentStage(
        paymentMethod: null, shippingAddress: null, items: List.empty(), cuponCode: "", shippingMethod: ShippingMethod.delivery));
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
      ],
      child: Sizer(
        builder: (ctx, orientation, type) => AppSystemManager(
          child: MaterialApp(
            title: 'Vivity',
            theme: lightTheme,
            home: Builder(builder: (ctxWithBloc) {
              return BlocListener<UserBloc, UserState>(
                listener: (ctx, userState) {
                  if (userState is UserLoggedOutState) {
                    ctxWithBloc.read<AuthBloc>().add(AuthLogoutEvent());
                    Navigator.popUntil(ctx, (route) => route.isFirst);
                    Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (ctx) => AuthPage()));
                  } else if (userState is UserLoggedInState) {
                    Navigator.popUntil(ctx, (route) => route.isFirst);
                    Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (ctx) => HomePage()));
                    ctxWithBloc.read<CartBloc>().add(CartSyncToUserStateEvent(userState));
                  }
                },
                child: AuthPage(),
              );
            }),
          ),
        ),
      ),
    );
  }
}
