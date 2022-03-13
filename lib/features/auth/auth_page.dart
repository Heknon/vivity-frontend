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

  late Future<String?> authenticateResult;
  bool onLoginModule = false;

  @override
  void initState() {
    super.initState();
    authenticateResult = authenticate();
    _tabController = TabController(length: 2, vsync: this);
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
            SvgPicture.asset(
              "assets/icons/abstract_logo.svg",
              color: primaryComplementaryColor,
              height: 110,
            ),
            SizedBox(height: 25),
            SvgPicture.asset(
              "assets/icons/text_logo_simple.svg",
              width: 90.w,
            ),
            SizedBox(height: 20),
            buildAuthenticationSplashscreen(),
          ],
        ),
      ),
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

  FutureBuilder<String?> buildAuthenticationSplashscreen() {
    return FutureBuilder<String?>(
      future: authenticateResult,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        if (snapshot.data?.isNotEmpty ?? false) {
          loginRoutine(snapshot.data!);
          return const CircularProgressIndicator();
        }

        return BlocConsumer<AuthBloc, AuthState>(
          listener: (ctx, state) {
            print(state);
          },
          builder: (ctx, state) {
            if (state.loggedIn) {
              loginRoutine(state.loginResult!);
              return const CircularProgressIndicator();
            }

            onLoginModule = state.previouslyLoggedIn;

            return Expanded(
              child: buildAuthModule(),
            );
          },
        );
      },
    );
  }

  void loginRoutine(String token) {
    BlocProvider.of<UserBloc>(context).add(UserLoginEvent(token));

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Navigator.push(context, MaterialPageRoute(builder: (ctx) => HomePage()));
    });
  }

  Future<String> authenticate() async {
    String? res = await BlocProvider.of<AuthBloc>(context).state.verifyCredentials();
    context.read<AuthBloc>().add(AuthUpdateEvent(res));
    return res ?? "a";
  }
}
