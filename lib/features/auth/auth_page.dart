import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/auth/bloc/auth_bloc.dart';
import 'package:vivity/features/auth/login_module.dart';
import 'package:vivity/features/auth/register_module.dart';
import 'package:vivity/features/home/home_page.dart';

import '../user/bloc/user_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool onLoginModule = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AuthBloc>(context).state.previouslyLoggedIn.then((value) => _tabController.index = value ? 0 : 1);
    sendAuthenticationRequestEvent();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffdddddd),
      body: SafeArea(
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
    );
  }

  Widget buildAuthenticationSplashscreen() {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthLoggedInState) {
          loginRoutine(state.token);
        } else if (state is AuthRegisterFailedState) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.reason.name),
            ),
          );
        }
      },
      builder: (ctx, state) {
        if (state is AuthLoadingState || state is AuthLoggedInState) {
          return const CircularProgressIndicator();
        }

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
                size: Size(100, 12.sp),
                child: Text(
                  'LOGIN',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline3!.copyWith(fontSize: 12.sp, color: fillerColor),
                ),
              ),
            ),
            Tab(
              child: SizedBox.fromSize(
                size: Size(100, 12.sp),
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
              LoginModule(),
              RegisterModule(),
            ],
          ),
        )
      ],
    );
  }

  void loginRoutine(String token) {
    BlocProvider.of<UserBloc>(context).add(UserLoginEvent(token));
  }

  void sendAuthenticationRequestEvent() async {
    context.read<AuthBloc>().add(AuthConfirmationEvent(false));
  }
}
