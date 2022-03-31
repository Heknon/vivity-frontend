import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivity/features/auth/auth_page.dart';
import 'package:vivity/features/drawer/vivity_drawer.dart';
import 'package:vivity/features/home/home_page.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/main.dart';
import 'package:vivity/widgets/appbar/appbar.dart';

import 'auth/bloc/auth_bloc.dart';

class BasePage extends StatelessWidget {
  final bool resizeToAvoidBottomInset;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;
  final void Function(BuildContext, UserState)? userStateListener;

  const BasePage({
    Key? key,
    this.resizeToAvoidBottomInset = false,
    this.appBar,
    this.drawer,
    this.body,
    this.userStateListener,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (ctx) => HomePage()));
        return true;
      },
      child: BlocListener<UserBloc, UserState>(
        listener: (ctx, state) {
          if (userStateListener != null) userStateListener!(ctx, state);
          if (state is UserLoggedOutState) {
            logoutRoutine(context);
          }
        },
        child: Scaffold(
          floatingActionButton: floatingActionButton,
          floatingActionButtonAnimator: floatingActionButtonAnimator,
          floatingActionButtonLocation: floatingActionButtonLocation,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          appBar: appBar ?? VivityAppBar(),
          drawer: drawer ?? const VivityDrawer(),
          body: body,
        ),
      ),
    );
  }
}

class BasePageBlocBuilder<B extends StateStreamable<S>, S> extends BasePage {
  final BlocWidgetBuilder<S> builder;
  final BlocBuilderCondition<S>? buildWhen;

  const BasePageBlocBuilder({
    Key? key,
    bool resizeToAvoidBottomInset = false,
    PreferredSizeWidget? appBar,
    Widget? drawer,
    required this.builder,
    this.buildWhen,
    void Function(BuildContext, UserState)? userStateListener,
  }) : super(
          key: key,
          body: null,
          appBar: appBar,
          drawer: drawer,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          userStateListener: userStateListener,
        );

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
        drawer: drawer ?? const VivityDrawer(),
        body: BlocBuilder<B, S>(
          builder: builder,
          buildWhen: buildWhen,
        ),
      ),
    );
  }
}
