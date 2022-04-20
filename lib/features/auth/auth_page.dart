import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/auth/bloc/auth_bloc.dart';
import 'package:vivity/features/auth/login_module.dart';
import 'package:vivity/features/auth/register_module.dart';
import 'package:vivity/features/auth/repo/authentication_repository.dart';
import 'package:vivity/features/cart/bloc/cart_bloc.dart';
import 'package:vivity/features/home/explore/bloc/explore_bloc.dart';
import 'package:vivity/features/like/bloc/liked_bloc.dart';
import 'package:vivity/helpers/ui_helpers.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late final AuthBloc _authBloc;
  final AuthenticationRepository _authRepository = AuthenticationRepository();

  TextEditingController _loginPasswordController = TextEditingController();
  LoadDialog _loadDialog = LoadDialog();

  bool onLoginModule = false;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _authBloc = BlocProvider.of<AuthBloc>(context);

    _authRepository.getPreviouslyLoggedIn().then((value) => _tabController.index = value ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    AuthState state = _authBloc.state;
    if (state is AuthLoggedInState) {
      Navigator.pushReplacementNamed(context, "/home/explore");
      BlocProvider.of<CartBloc>(context).add(CartSyncEvent());
      BlocProvider.of<LikedBloc>(context).add(LikedLoadEvent());
      BlocProvider.of<ExploreBloc>(context).add(ExploreLoad());
    }

    return Scaffold(
      backgroundColor: const Color(0xffdddddd),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (ctx, state) {
            if (state is AuthLoggedInState) {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }

              Navigator.pushReplacementNamed(context, "/home/explore");
              BlocProvider.of<CartBloc>(context).add(CartSyncEvent());
              BlocProvider.of<LikedBloc>(context).add(LikedLoadEvent());
              BlocProvider.of<ExploreBloc>(context).add(ExploreLoad());
            } else if (state is AuthFailedState) {
              showSnackBar(state.message ?? "Authentication failed", context);
              _loginPasswordController.text = "";

              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            } else if (state is AuthLoadingState) {
              showDialog(context: context, builder: (ctx) => _loadDialog);
            }
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
              Expanded(
                child: buildAuthModule(),
              ),
            ],
          ),
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
}
