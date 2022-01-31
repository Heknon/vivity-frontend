import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/light_theme.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/features/item/item_page.dart';

import 'features/home/home_page.dart';

class VivityOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = VivityOverrides();
  runApp(const Vivity());
}

class Vivity extends StatelessWidget {
  const Vivity({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (ctx, orientation, type) => MaterialApp(
        title: 'Vivity',
        theme: lightTheme,
        home: ItemPage(
          itemModel: itemModelDemo2,
        ),
      ),
    );
  }
}
