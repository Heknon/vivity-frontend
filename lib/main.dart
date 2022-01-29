import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/light_theme.dart';
import 'package:vivity/constants/app_constants.dart';
import 'package:vivity/features/item/item_page.dart';

import 'features/home/home_page.dart';

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
        home: ItemPage(itemModel: itemModelDemo2,),
      ),
    );
  }
}

