import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vivity/features/drawer/vivity_drawer.dart';
import 'package:vivity/widgets/appbar/appbar.dart';

class BasePage extends StatelessWidget {
  final bool resizeToAvoidBottomInset;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? body;

  const BasePage({
    Key? key,
    this.resizeToAvoidBottomInset = false,
    this.appBar,
    this.drawer,
    this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar ?? VivityAppBar(),
      drawer: drawer ?? VivityDrawer(),
      body: body,
    );
  }
}
