import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/business/business_items_page.dart';
import 'package:vivity/features/business/business_orders_page.dart';
import 'package:vivity/features/item/item_creation_dialog.dart';

import '../../widgets/appbar/appbar.dart';
import '../user/bloc/user_bloc.dart';
import 'business_statistics_page.dart';

class BusinessPage extends StatelessWidget {
  const BusinessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserState state = context.read<UserBloc>().state;
    if (state is! BusinessUserLoggedInState) {
      Navigator.pushReplacementNamed(context, '/business/create');
      return CircularProgressIndicator();
    }

    if (!state.business.approved) {
      Navigator.pushReplacementNamed(context, '/business/unapproved');
      return CircularProgressIndicator();
    }

    return DefaultTabController(
      length: 3,
      child: BasePage(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(context: context, builder: (ctx) {
              return ItemCreationDialog();
            });
          },
          backgroundColor: primaryComplementaryColor,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        appBar: VivityAppBar(
          bottom: const TabBar(
            tabs: [
              Tab(text: "Items"),
              Tab(text: "Orders"),
              Tab(text: "Statistics"),
            ],
            indicatorColor: Colors.white,
          ),
        ),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is! BusinessUserLoggedInState) {
              return const Text('One of two things: You are either not logged in or don\'t own a business.\nEither way, how are you here 🤨');
            }

            return TabBarView(
              children: [
                BusinessItemsPage(),
                BusinessOrdersPage(),
                BusinessStatisticsPage(),
              ],
            );
          },
        ),
      ),
    );
  }
}
