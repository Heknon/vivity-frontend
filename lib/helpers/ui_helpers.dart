import 'dart:async';

import 'package:flutter/widgets.dart';

Future<RenderBox> getRenderBox(GlobalKey key) async {

  Completer<RenderBox> completer = Completer();

  WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    final GlobalKey currKey = key;
    final RenderBox box = currKey.currentContext?.findRenderObject() as RenderBox;
    completer.complete(box);
  });

  return completer.future;
}
