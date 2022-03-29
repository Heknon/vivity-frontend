import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/features/item/item_page.dart';

var itemHandler = Handler(handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
  return ItemPage(
    item: null,
  );
});