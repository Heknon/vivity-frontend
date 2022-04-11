import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/drawer/vivity_drawer.dart';
import 'package:vivity/features/user/bloc/user_bloc.dart';
import 'package:vivity/widgets/appbar/appbar.dart';
import '../explore/explore.dart';
import 'feed/feed.dart';

class HomePage extends StatelessWidget {
  final int initial;
  final LoadDialog _loadDialog = LoadDialog();

  HomePage({Key? key, this.initial = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      UserState state = context.read<UserBloc>().state;
      if (state is! UserLoggedInState && !Navigator.canPop(context)) {
        showDialog(context: context, builder: (ctx) => _loadDialog);
      }
    });

    return DefaultTabController(
      length: 2,
      initialIndex: initial,
      child: BlocListener<UserBloc, UserState>(
        listenWhen: (prevState, state) => prevState is! UserLoggedInState && state is UserLoggedInState,
        listener: (ctx, state) {
          if (Navigator.canPop(ctx)) Navigator.pop(ctx);
        },
        child: BasePage(
          appBar: VivityAppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: "Explore"),
                Tab(text: "Feed"),
              ],
              indicatorColor: Colors.white,
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Explore(),
              Feed(),
            ],
          ),
        ),
      ),
    );
  }
}
