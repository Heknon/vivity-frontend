import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivity/features/auth/auth_page.dart';
import 'package:vivity/features/drawer/vivity_drawer.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/main.dart';
import 'package:vivity/widgets/appbar/appbar.dart';

import 'auth/bloc/auth_bloc.dart';

class BasePage extends StatelessWidget {
  final bool resizeToAvoidBottomInset;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? body;
  final void Function(BuildContext, UserState)? userStateListener;

  const BasePage({
    Key? key,
    this.resizeToAvoidBottomInset = false,
    this.appBar,
    this.drawer,
    this.body,
    this.userStateListener,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (ctx, state) {
        if (userStateListener != null) userStateListener!(ctx, state);
        if (state is UserLoggedOutState) {
          logoutRoutine(context);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: appBar ?? VivityAppBar(),
        drawer: drawer ?? VivityDrawer(),
        body: body,
      ),
    );
  }
}