import 'package:flutter/material.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/utils/helpers/color_helpers.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  primaryColor: createMaterialColor(primaryColor),
);
