import 'package:flutter/material.dart';
import 'package:vivity/config/themes/themes_config.dart';
import '../../helpers/color_helpers.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: createMaterialColor(primaryColor),
    colorScheme: ColorScheme.light(primary: primaryColor, secondary: primaryComplementaryColor, primaryVariant: primaryColorVariant),
    dialogBackgroundColor: const Color(0xfff5f5f5),
    textTheme: Typography.blackCupertino.copyWith(
      subtitle2: TextStyle(fontFamily: "Hezaedrus", fontSize: 10, color: Colors.grey[600]),
      headline4: TextStyle(
        fontFamily: "Hezaedrus",
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryColor,
      ),
    ));
