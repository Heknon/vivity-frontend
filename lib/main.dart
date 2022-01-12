import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/light_theme.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/modules/user/screens/home_page.dart';
import 'package:vivity/utils/helpers/color_helpers.dart';

void main() {
  runApp(const Vivity());
}

class Vivity extends StatelessWidget {
  const Vivity({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (ctx, orientation, type) =>  MaterialApp(
        title: 'Vivity',
        theme: lightTheme,
        home: HomePage(),
      ),
    );
  }
}

