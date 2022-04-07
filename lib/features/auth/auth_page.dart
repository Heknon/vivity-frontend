import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:no_interaction_dialog/no_interaction_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/auth/auth_result.dart';
import 'package:vivity/features/auth/bloc/auth_bloc.dart';
import 'package:vivity/features/auth/login_module.dart';
import 'package:vivity/features/auth/register_module.dart';
import 'package:vivity/features/auth/register_result.dart';
import 'package:vivity/main.dart' as main;

import '../user/bloc/user_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late NoInteractionDialogController _dialogController;
  late LoadDialog _loadDialog;

  late TextEditingController _loginPasswordController;

  late bool sentAuthRequest;
  bool onLoginModule = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthBloc>(context).state.previouslyLoggedIn.then((value) => _tabController.index = value ? 0 : 1);
    sentAuthRequest = false;
    sendAuthenticationRequestEvent();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _dialogController = NoInteractionDialogController(isOpen: false);
    _loadDialog = LoadDialog(controller: _dialogController);
    _loginPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdddddd),
      body: SafeArea(
        child: BlocListener<UserBloc, UserState>(
          listener: (ctx, state) {
            if (state is UserLoggedInState) main.loginRoutine(state, context);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Center(
                child: SvgPicture.asset(
                  "assets/icons/abstract_logo.svg",
                  color: primaryComplementaryColor,
                  height: 110,
                ),
              ),
              SizedBox(height: 25),
              Center(
                child: SvgPicture.asset(
                  "assets/icons/text_logo_simple.svg",
                  width: 90.w,
                ),
              ),
              SizedBox(height: 20),
              buildAuthenticationSplashscreen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAuthenticationSplashscreen() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (ctx, state) async {
        if (state is AuthLoggedInState) {
          loginRoutine(state.authResult);
        } else if (state is AuthRegisterFailedState) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.reason.name),
          ));
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _loginPasswordController.text = "";
          }
        } else if (state is AuthLoggedOutState && state.status != null) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _loginPasswordController.text = "";
          }
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.status!.getMessage()),
          ));
        } else if (state is AuthLoggedOutState) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            _loginPasswordController.text = "";
          }
        }

        if (state is AuthLoadingState || state is AuthLoggedInState || context.read<UserBloc>().state is UserLoadingState) {
          showDialog(context: context, builder: (ctx) => _loadDialog);
        }
      },
      builder: (ctx, state) {
        return Expanded(
          child: buildAuthModule(),
        );
      },
    );
  }

  Widget buildAuthModule() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: primaryComplementaryColor,
          tabs: [
            Tab(
              child: SizedBox.fromSize(
                size: Size(100, 15.sp),
                child: Text(
                  'LOGIN',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 12.sp, color: fillerColor),
                ),
              ),
            ),
            Tab(
              child: SizedBox.fromSize(
                size: Size(100, 15.sp),
                child: Text(
                  'REGISTER',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 12.sp, color: fillerColor),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              LoginModule(passwordController: _loginPasswordController),
              RegisterModule(),
            ],
          ),
        )
      ],
    );
  }

  void loginRoutine(AuthResult authResult) {
    _dialogController.close();
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    BlocProvider.of<UserBloc>(context).add(UserLoginEvent(authResult.accessToken));
  }

  void sendAuthenticationRequestEvent() async {
    context.read<AuthBloc>().add(AuthConfirmationEvent(false));
    sentAuthRequest = true;
  }
}
