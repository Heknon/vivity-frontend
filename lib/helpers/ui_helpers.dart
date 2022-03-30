import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sizer/sizer.dart';

Future<RenderBox> getRenderBox(GlobalKey key) async {
  Completer<RenderBox> completer = Completer();

  WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    final GlobalKey currKey = key;
    final RenderBox box = currKey.currentContext?.findRenderObject() as RenderBox;
    completer.complete(box);
  });

  return completer.future;
}

Widget gradientBackground({required Widget child, required List<Color> colors, required List<double> stops}) {
  return Container(
    height: 100.h - kToolbarHeight,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
        stops: stops,
      ),
    ),
    child: child,
  );
}

Widget defaultGradientBackground({required Widget child}) {
  return gradientBackground(child: child, colors: [Color(0xffF3F1F2), Color(0xffEAEAEC)], stops: [0, 1]);
}

Size getTextSize(Text text) {
  final TextPainter textPainter =
      TextPainter(text: TextSpan(text: text.data, style: text.style), maxLines: 1, textDirection: text.textDirection ?? TextDirection.ltr)
        ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}
