import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String abstractLogoIcon = "assets/icons/abstract_logo.svg";
Uint8List? noImageAvailable;

Future<void> loadImageAssets() async {
  noImageAvailable = (await rootBundle.load("assets/images/no_image_available.png")).buffer.asUint8List();
}