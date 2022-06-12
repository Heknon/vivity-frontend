import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vivity/config/themes/themes_config.dart';
import 'package:vivity/features/base_page.dart';
import 'package:vivity/features/business/bloc/business_bloc.dart';
import 'package:vivity/features/business/business_items_page.dart';
import 'package:vivity/features/business/business_orders_page.dart';
import 'package:vivity/features/item/item_creation_dialog.dart';

import '../../widgets/appbar/appbar.dart';
import 'business_statistics_page.dart';

class BusinessPage extends StatefulWidget {
  const BusinessPage({Key? key}) : super(key: key);

  @override
  State<BusinessPage> createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  late final BusinessBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = context.read<BusinessBloc>();
  }

  @override
  Widget build(BuildContext context) {
    BusinessState state = _bloc.state;
    if (state is! BusinessUnloaded && state is BusinessNoBusiness) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        Navigator.pushReplacementNamed(context, '/business/create');
      });
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is BusinessLoaded && !state.business.approved) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        Navigator.pushReplacementNamed(context, '/business/unapproved');
      });
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return DefaultTabController(
      length: 3,
      child: BasePage(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (ctx) {
                  return ItemCreationDialog(
                    onCreateItem: (item) => _bloc.add(BusinessCreateItemEvent(item)),
                  );
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
        body: BlocConsumer<BusinessBloc, BusinessState>(
          listener: (context, state) {
            if (state is BusinessNoBusiness) {
              Navigator.pushReplacementNamed(context, '/business/create');
            } else if (state is BusinessLoaded && !state.business.approved) {
              Navigator.pushReplacementNamed(context, '/business/unapproved');
            }
          },
          builder: (context, state) {
            if (state is! BusinessLoaded) {
              return Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              children: [
                BusinessItemPage(business: state.business, items: state.items, businessBloc: _bloc),
                BusinessOrdersPage(business: state.business, orderItems: state.orderItems, orders: state.orders, businessBloc: _bloc),
                BusinessStatisticsPage(business: state.business, items: state.items, orders: state.orders),
              ],
            );
          },
        ),
      ),
    );
  }
}
