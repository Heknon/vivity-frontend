import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:no_interaction_dialog/load_dialog.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/home/bloc/home_bloc.dart';
import 'package:vivity/features/home/explore/bloc/explore_bloc.dart';
import 'package:vivity/widgets/appbar/appbar.dart';
import 'explore/explore.dart';
import 'feed/feed.dart';

class HomePage extends StatefulWidget {
  final int initial;

  HomePage({Key? key, this.initial = 0}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeBloc _homeBloc;
  final LoadDialog _loadDialog = LoadDialog();
  bool loadDialogOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _homeBloc = context.read<HomeBloc>();
  }

  @override
  Widget build(BuildContext context) {
    HomeState homeState = _homeBloc.state;
    if ((homeState is HomeLoading || homeState is HomeBlocked) && !loadDialogOpen) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        showDialog(context: context, builder: (ctx) => _loadDialog);
      });
      loadDialogOpen = true;
    }

    return DefaultTabController(
      length: 2,
      initialIndex: widget.initial,
      child: BlocListener<HomeBloc, HomeState>(
        listener: (ctx, state) {
          if (state is HomeLoaded && loadDialogOpen) {
            Navigator.pop(context);
          }
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
              BlocProvider(
                create: (ctx) {
                  ExploreBloc bloc = ExploreBloc();
                  bloc.add(ExploreLoad());
                  return bloc;
                },
                child: Explore(),
              ),
              Feed(),
            ],
          ),
        ),
      ),
    );
  }
}
