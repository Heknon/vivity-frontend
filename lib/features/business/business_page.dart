import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/business/business_items_page.dart';
import 'package:vivity/features/business/business_orders_page.dart';

import '../../widgets/appbar/appbar.dart';
import '../user/bloc/user_bloc.dart';
import 'business_statistics_page.dart';

class BusinessPage extends StatelessWidget {
  const BusinessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BasePage(
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
                BusinessItemsPage(business: state.business),
                BusinessOrdersPage(business: state.business),
                BusinessStatisticsPage(business: state.business),
              ],
            );
          },
        ),
      ),
    );
  }
}
