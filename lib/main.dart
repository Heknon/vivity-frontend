import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/light_theme.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/services/storage_service.dart';
import 'package:vivity/features/item/item_page.dart';

import 'features/cart/cart_bloc/cart_bloc.dart';
import 'features/home/home_page.dart';

class VivityOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}


// TODO: Create checkout pages/process
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
    return BlocProvider(
      create: (ctx) => CartBloc(),
      child: Sizer(
        builder: (ctx, orientation, type) =>
            MaterialApp(
              title: 'Vivity',
              theme: lightTheme,
              home: HomePage(),
            ),
      ),
    );
  }
}
