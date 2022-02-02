import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:vivity/features/item/item_page.dart';

var usersHandler = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return ItemPage(
    itemModel: itemModel,
  );
});