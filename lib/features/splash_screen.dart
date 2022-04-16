import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/helpers/ui_helpers.dart';

import '../config/themes/themes_config.dart';

class SplashScreen<T> extends StatefulWidget {
  final Future<T> future;
  final void Function(BuildContext context, AsyncSnapshot<T> snapshot)? onComplete;
  final Duration timeout;

  /// Waits for future to be complete and then calls onComplete
  SplashScreen({
    Key? key,
    required this.future,
    this.onComplete,
    this.timeout = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<SplashScreen<T>> createState() => _SplashScreenState<T>();
}

class _SplashScreenState<T> extends State<SplashScreen<T>> {
  @override
  void initState() {
    super.initState();

    widget.future.then((value) {
      if (widget.onComplete != null) widget.onComplete!(context, AsyncSnapshot.withData(ConnectionState.done, value));
    }).catchError((err) {
      if (widget.onComplete != null) widget.onComplete!(context, AsyncSnapshot.withError(ConnectionState.done, err));
    }).timeout(widget.timeout, onTimeout: () {
      if (widget.onComplete != null) widget.onComplete!(context, AsyncSnapshot.nothing());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: defaultGradientBackground(
        child: SizedBox(
          width: 100.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
